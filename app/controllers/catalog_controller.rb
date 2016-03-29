# -*- encoding : utf-8 -*-
# require 'blacklight/catalog'
require 'zip'
require 'fastimage'

class CatalogController < ApplicationController

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include Ddr::Models::Catalog
  include Ddr::Public::Controller::ConfigureBlacklight

  self.search_params_logic += [:include_only_published]

  helper_method :get_search_results
  helper_method :configure_blacklight_for_children

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      forbidden
    else
      authenticate_user!
    end
  end

  layout 'blacklight'

  configure_blacklight do |config|
    config.search_builder_class = SearchBuilder
    config.show.route = {}
          config.view.gallery.partials = [:index_header, :index]

          config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
          config.show.partials.insert(1, :openseadragon)

    # TODO: Should the qf be set in the solr config?
    config.default_solr_params = {
      :qt => 'search',
      :rows => 20,
      :qf => ["id",
              solr_name(:dc_title, :stored_searchable),
              solr_name(:dc_creator, :stored_searchable),
              solr_name(:dc_contributor, :stored_searchable),
              solr_name(:dc_subject, :stored_searchable),
              solr_name(:dc_type, :stored_searchable),
              solr_name(:dc_publisher, :stored_searchable),
              solr_name(:duketerms_series, :stored_searchable),
              solr_name(:dc_description, :stored_searchable),
              solr_name(:dc_abstract, :stored_searchable),
              Ddr::Index::Fields::YEAR_FACET,
              solr_name(:dc_spatial, :stored_searchable),
              Ddr::Index::Fields::LOCAL_ID,
              solr_name(:dc_identifier, :stored_searchable),
              Ddr::Index::Fields::PERMANENT_ID].join(' ')
    }

    config.per_page = [10,20,50,100]
    config.default_per_page = 20
    config.max_per_page = 100

    # solr field configuration for search results/index views
    config.index.title_field = Ddr::Index::Fields::TITLE.to_s
    config.index.active_fedora_model_field = Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s
    config.index.display_type_field = Ddr::Index::Fields::DISPLAY_FORMAT.to_s

    config.index.thumbnail_method = :thumbnail_image_tag

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _tsimed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    # config.add_facet_field solr_name('object_type', :facetable), :label => 'Format'
    # config.add_facet_field solr_name('pub_date', :facetable), :label => 'Publication Year'
    # config.add_facet_field solr_name('subject_topic', :facetable), :label => 'Topic', :limit => 20
    # config.add_facet_field solr_name('language', :facetable), :label => 'Language', :limit => true
    # config.add_facet_field solr_name('lc1_letter', :facetable), :label => 'Call Number'
    # config.add_facet_field solr_name('subject_geo', :facetable), :label => 'Region'
    # config.add_facet_field solr_name('subject_era', :facetable), :label => 'Era'
    # config.add_facet_field Ddr::Index::Fields::ADMIN_SET_FACET.to_s, label: 'Collection Group', helper_method: 'admin_set_full_name', collapse: false, limit: 5
    # config.add_facet_field Ddr::Index::Fields::COLLECTION_FACET.to_s, label: 'Collection', helper_method: 'collection_title', limit: 5
    # config.add_facet_field Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s, label: 'Browse', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name(:dc_creator, :stored_searchable), separator: '; ', label: 'Creator'
    config.add_index_field solr_name(:dc_date, :stored_searchable), separator: '; ', label: 'Date'
    config.add_index_field solr_name(:dc_type, :stored_searchable), separator: '; ', label:'Type'
    config.add_index_field Ddr::Index::Fields::PERMANENT_URL.to_s, helper_method: 'permalink', label: 'Permalink'
    config.add_index_field Ddr::Index::Fields::MEDIA_TYPE.to_s, helper_method: 'file_info', label: 'File'
    config.add_index_field :isPartOf_ssim, helper_method: 'descendant_of', label: 'Part of'
    config.add_index_field :isMemberOfCollection_ssim, helper_method: 'descendant_of', label: 'Collection'
    config.add_index_field Ddr::Index::Fields::COLLECTION_URI.to_s, helper_method: 'descendant_of', label: 'Collection'

    config.default_document_solr_params = {
      fq: ["#{Ddr::Index::Fields::WORKFLOW_STATE}:published"]
    }

    # partials for show view
    config.show.partials = [:show_header, :show, :show_children]

    # deactivate certain tools
    config.show.document_actions.delete(:email)
    config.show.document_actions.delete(:sms)
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:refworks)
    config.show.document_actions.delete(:endnote)
    config.show.document_actions.delete(:librarian_view)

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name(:dc_title, :stored_searchable), separator: '; ', label: 'Title'
    config.add_show_field Ddr::Index::Fields::PERMANENT_URL.to_s, helper_method: 'permalink', label: 'Permalink'
    config.add_show_field Ddr::Index::Fields::MEDIA_TYPE.to_s, helper_method: 'file_info', label: 'File'
    config.add_show_field solr_name(:dc_creator, :stored_searchable), separator: '; ', label: 'Creator'
    config.add_show_field solr_name(:dc_date, :stored_searchable), separator: '; ', label: 'Date'
    config.add_show_field solr_name(:dc_type, :stored_searchable), separator: '; ', label: 'Type'

    (Ddr::Models::DescriptiveMetadata.field_names - [ :dc_title, :dc_creator, :dc_date, :dc_type ]).each do |term_name|
      config.add_show_field solr_name(term_name, :stored_searchable), separator: '; ', label: term_name.to_s.gsub(/^(dc|duketerms)_/, "").titleize
    end

    config.add_show_field :isPartOf_ssim, helper_method: 'descendant_of', label: 'Part of'
    config.add_show_field :isMemberOfCollection_ssim, helper_method: 'descendant_of', label: 'Collection'
    config.add_show_field Ddr::Index::Fields::COLLECTION_URI.to_s, helper_method: 'descendant_of', label: 'Collection'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    config.add_search_field 'all_fields', :label => 'All Fields' do |field|
      field.solr_local_parameters = {
        :qf => "id dc_title_tesim dc_creator_tesim dc_subject_tesim dc_description_tesim dc_identifier_tesim #{Ddr::Index::Fields::PERMANENT_ID}"
      }
    end


    # Now we see how to over-ride Solr request handler defaults, in this
    # case for a BL "search field", which is really a dismax aggregate
    # of Solr search fields.

    config.add_search_field('title') do |field|
      # :solr_local_parameters will be sent using Solr LocalParams
      # syntax, as eg {! qf=$title_qf }. This is neccesary to use
      # Solr parameter de-referencing like $title_qf.
      # See: http://wiki.apache.org/solr/LocalParams
      field.solr_local_parameters = {
        :qf => '$title_qf',
        :pf => '$title_pf'
      }
    end

    config.add_search_field('creator') do |field|
      field.solr_local_parameters = {
        :qf => solr_name(:creator, :stored_searchable),
        :pf => ''
      }
    end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    config.add_search_field('subject') do |field|
      field.qt = 'search'
      field.solr_local_parameters = {
        :qf => '$subject_qf',
        :pf => '$subject_pf'
      }
    end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc, pub_date_dtsi desc, title_tesi asc', :label => 'relevance'
    config.add_sort_field "#{Ddr::Index::Fields::TITLE} asc", :label => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Maximum number of results to show per page
    config.max_per_page = 999
  end

  def show
    super
    multires_image_file_paths
  end

  def exclude_components(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "-#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Component"
  end

  def configure_blacklight_for_children
    blacklight_config.configure do |config|
      config.sort_fields.clear
      config.add_sort_field "#{Ddr::Index::Fields::TITLE} asc", label: "Title"
      config.add_sort_field "#{Ddr::Index::Fields::LOCAL_ID} asc", label: "Local ID"
    end
  end

  def multires_image_file_paths
    @document_multires_image_file_paths ||= @document.multires_image_file_paths || []
  end

  # For portal scoping
  def construct_solr_parameter_value opts = {} # opts[:solr_field, :boolean_operator => 'OR', :values => []]
    solr_parameter_value = ""
    opts[:values].each do |value|
      segment = opts[:solr_field] + ":\"" + value + "\""
      if opts[:boolean_operator].present?
        segment << " " + opts[:boolean_operator] + " "
      end
      solr_parameter_value << segment
    end
    if opts[:boolean_operator].present?
      solr_parameter_value.gsub!(/\s#{Regexp.escape opts[:boolean_operator]}\s$/, "")
    end
    solr_parameter_value
  end


  def zip_images

    # TO-DO: make the image_list param a real array or hash instead of delimited string
    image_list = params[:image_list].split('||')
    itemid = params[:itemid]


    # Combination of these techniques:
    #   http://thinkingeek.com/2013/11/15/create-temporary-zip-file-send-response-rails/
    #   https://github.com/rubyzip/rubyzip#basic-zip-archive-creation

    t = Tempfile.new("temp-ddr-#{Time.now.utc}")
    Zip::OutputStream.open(t.path) do |z|
      image_list.each_with_index do |item, index|
        title = item.to_s
        z.put_next_entry("#{index+1}.jpg")

        # TODO: use DPC ID for the component filename OR extract the ptif path basename.

        url1 = item
        url1_data = open(url1, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE })
        z.print IO.read(url1_data)

        # TODO: update a progress bar to indicate status.
        # TODO: write a test for this feature.

      end


      send_file t.path, :type => 'application/zip',
                                   :disposition => 'attachment',
                                   :filename => itemid+".zip"

            t.close
    end
  end

  def pdf_images
    image_list = params[:image_list].split('||')
    itemid = params[:itemid]


    # A4 pixel dimensions are W: 595.28 x H: 841.89 so we should aim to keep our PDFs around that size.
    # Let's use 1000 on long side.

    pdf = Prawn::Document.new({ :margin => 0, :skip_page_creation => true })

    image_list.each_with_index do | file, index |

      # New document, A4 paper, landscaped
      # pdf = Prawn::Document.new(:page_size => "A4", :page_layout => :landscape)


      image_size = FastImage.size(file) # returns [w,h]

      image_w = image_size[0]
      image_h = image_size[1]

      # aspect ratio (w/h)
      image_r = image_w.to_f / image_h.to_f

      if image_r >= 1 # landscape
        pg_w = 1000
        pg_h = 1000 / image_r
      else
        pg_w = 1000 * image_r
        pg_h = 1000
      end

      # For small-derivative source image: PDF page will be full-size
      if image_w < 1000 && image_h < 1000
        pg_w = image_w.to_i
        pg_h = image_h.to_i
      end

      # Note: keep layout => :portrait even for landscape images else they don't render correctly
      pdf.start_new_page(:size => [pg_w, pg_h], :layout => :portrait, :margin => 0)
      y_pos = pdf.cursor   # Record the top y value (y=0 is the bottom of the page)
      pdf.image open(file, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }), :at => [0, y_pos], :fit => [pg_w, pg_h]

    end


    send_data pdf.render, filename: itemid+'.pdf', type: 'application/pdf'

  end


  protected

  def forbidden
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
  end

end
