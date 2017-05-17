# -*- encoding : utf-8 -*-
require 'zip'
require 'fastimage'

class CatalogController < ApplicationController

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include Ddr::Public::Controller::ConfigureBlacklight


  before_action :authenticate_user!, if: :authentication_required?
  before_action :enforce_show_permissions, only: :show

  self.search_params_logic += [:include_only_published, :apply_access_controls]

  helper_method :repository, :search_builder

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

    config.default_solr_params = {
      :qt => 'search',
      :rows => 20
    }

    config.per_page = [10,20,50,100]
    config.default_per_page = 20
    config.max_per_page = 999

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
    # config.add_facet_field Ddr::Index::Fields::ADMIN_SET_TITLE.to_s, label: 'Collection Group', collapse: false, limit: 5
    # config.add_facet_field Ddr::Index::Fields::COLLECTION_TITLE.to_s, label: 'Collection', limit: 5
    # config.add_facet_field Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s, label: 'Browse', show: false

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name(:creator, :stored_searchable), separator: '; ', label: 'Creator'
    config.add_index_field solr_name(:date, :stored_searchable), helper_method: 'display_edtf_date', separator: '; ', label: 'Date'
    config.add_index_field solr_name(:type, :stored_searchable), separator: '; ', label:'Type'
    config.add_index_field Ddr::Index::Fields::PERMANENT_URL.to_s, helper_method: 'permalink', label: 'Permalink'
    config.add_index_field Ddr::Index::Fields::MEDIA_TYPE.to_s, helper_method: 'file_info', label: 'File'
    config.add_index_field Ddr::Index::Fields::IS_PART_OF.to_s, helper_method: 'descendant_of', label: 'Part of'
    config.add_index_field Ddr::Index::Fields::IS_MEMBER_OF_COLLECTION.to_s, helper_method: 'descendant_of', label: 'Collection'
    config.add_index_field Ddr::Index::Fields::COLLECTION_URI.to_s, helper_method: 'descendant_of', label: 'Collection'

    # partials for show view
    config.show.partials = [:show_header, :show, :show_children, :show_bottom]

    # deactivate certain tools
    config.show.document_actions.delete(:email)
    config.show.document_actions.delete(:sms)
    config.show.document_actions.delete(:citation)
    config.show.document_actions.delete(:refworks)
    config.show.document_actions.delete(:endnote)
    config.show.document_actions.delete(:librarian_view)

    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    config.add_show_field solr_name(:title, :stored_searchable), separator: '; ', label: 'Title'
    config.add_show_field Ddr::Index::Fields::PERMANENT_URL.to_s, helper_method: 'permalink', label: 'Permalink'
    config.add_show_field Ddr::Index::Fields::MEDIA_TYPE.to_s, helper_method: 'file_info', label: 'File'
    config.add_show_field solr_name(:creator, :stored_searchable), separator: '; ', label: 'Creator'
    config.add_show_field solr_name(:date, :stored_searchable), helper_method: 'display_edtf_date', separator: '; ', label: 'Date'
    config.add_show_field solr_name(:type, :stored_searchable), separator: '; ', label: 'Type'

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
        :qf => ["id",
                solr_name(:abstract, :stored_searchable),
                solr_name(:alternative, :stored_searchable),
                solr_name(:artist, :stored_searchable),
                solr_name(:bibliographicCitation, :stored_searchable),
                solr_name(:box_number, :stored_searchable),
                solr_name(:call_number, :stored_searchable),
                solr_name(:category, :stored_searchable),
                solr_name(:company, :stored_searchable),
                solr_name(:composer, :stored_searchable),
                solr_name(:creator, :stored_searchable),
                solr_name(:contributor, :stored_searchable),
                solr_name(:description, :stored_searchable),
                solr_name(:dedicatee, :stored_searchable),
                solr_name(:engraver, :stored_searchable),
                solr_name(:extent, :stored_searchable),
                solr_name(:folder, :stored_searchable),
                solr_name(:format, :stored_searchable),
                solr_name(:genre, :stored_searchable),
                solr_name(:headline, :stored_searchable),
                solr_name(:identifier, :stored_searchable),
                solr_name(:illustrated,:stored_searchable),
                solr_name(:illustrator,:stored_searchable),
                solr_name(:instrumentation, :stored_searchable),
                solr_name(:interviewer_name, :stored_searchable),
                solr_name(:isPartOf, :stored_searchable),
                solr_name(:issue_number, :stored_searchable),
                solr_name(:language_name, :stored_searchable),
                solr_name(:lithographer, :stored_searchable),
                solr_name(:lyricist, :stored_searchable),
                solr_name(:medium, :stored_searchable),
                solr_name(:negative_number, :stored_searchable),
                solr_name(:oclc_number, :stored_searchable),
                solr_name(:performer, :stored_searchable),
                solr_name(:placement_company, :stored_searchable),
                solr_name(:print_number, :stored_searchable),
                solr_name(:producer, :stored_searchable),
                solr_name(:product, :stored_searchable),
                solr_name(:provenance, :stored_searchable),
                solr_name(:publication, :stored_searchable),
                solr_name(:publisher, :stored_searchable),
                solr_name(:rights, :stored_searchable),
                solr_name(:roll_number, :stored_searchable),
                solr_name(:series, :stored_searchable),
                solr_name(:setting, :stored_searchable),
                solr_name(:spatial, :stored_searchable),
                solr_name(:sponsor, :stored_searchable),
                solr_name(:subject, :stored_searchable),
                solr_name(:subseries, :stored_searchable),
                solr_name(:temporal, :stored_searchable),
                solr_name(:title, :stored_searchable),
                solr_name(:tone, :stored_searchable),
                solr_name(:type, :stored_searchable),
                solr_name(:volume, :stored_searchable),
                Ddr::Index::Fields::ALL_TEXT,
                Ddr::Index::Fields::LOCAL_ID,
                Ddr::Index::Fields::PERMANENT_ID,
                Ddr::Index::Fields::YEAR_FACET].join(' ')
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
    config.add_sort_field "score desc, #{Ddr::Index::Fields::DATE_SORT} asc, #{Ddr::Index::Fields::TITLE} asc", :label => 'relevance'
    config.add_sort_field "#{Ddr::Index::Fields::TITLE} asc", :label => 'title'
    config.add_sort_field "#{Ddr::Index::Fields::DATE_SORT} asc", :label => 'date (old to new)'
    config.add_sort_field "#{Ddr::Index::Fields::DATE_SORT} desc", :label => 'date (new to old)'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

  end

  def zip_images
    image_list = params[:image_list].split('||')
    itemid = params[:itemid]

    # Combination of these techniques:
    #   http://thinkingeek.com/2013/11/15/create-temporary-zip-file-send-response-rails/
    #   https://github.com/rubyzip/rubyzip#basic-zip-archive-creation

    t = Tempfile.new("temp-ddr-#{Time.now.utc}")
    Zip::OutputStream.open(t.path) do |z|
      image_list.each_with_index do |item, index|
        path = item.to_s
        ptifname = path.split(".ptif")[0]
        filename = File.basename(ptifname)
        z.put_next_entry("#{index+1}-" + filename + ".jpg")

        url1 = item
        url1_data = open(url1, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE })
        z.print IO.read(url1_data)

        # TODO: update a progress bar to indicate status.
        # TODO: write a test for this feature.

      end

      send_file t.path, :type => 'application/zip', :disposition => 'attachment', :filename => itemid+".zip"
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

  def not_found
    render file: "#{Rails.root}/public/404", status: 404, layout: false
  end

  def authentication_required?
    Ddr::Public.require_authentication
  end

  def enforce_show_permissions
    begin
      authorize! :read, params[:id]
    rescue SolrDocument::NotFound
      not_found
    end
  end


end
