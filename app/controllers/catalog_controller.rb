# -*- encoding : utf-8 -*-
require 'blacklight/catalog'

class CatalogController < ApplicationController

  include Blacklight::Catalog
  include Hydra::Controller::ControllerBehavior
  include Hydra::PolicyAwareAccessControlsEnforcement

  before_action :enforce_show_permissions, only: :show

  CatalogController.solr_search_params_logic += [:add_access_controls_to_solr_params]
  CatalogController.solr_search_params_logic += [:include_only_published]

  helper_method :get_search_results
  helper_method :configure_blacklight_for_children

  rescue_from CanCan::AccessDenied do |exception|
    if user_signed_in?
      forbidden
    else
      authenticate_user!
    end
  end

  configure_blacklight do |config|
    config.default_solr_params = {
      :qt => 'search',
      :rows => 10
    }

    # solr field configuration for search results/index views
    config.index.title_field = Ddr::IndexFields::TITLE
    config.index.display_type_field = Ddr::IndexFields::ACTIVE_FEDORA_MODEL

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
    config.add_facet_field Ddr::IndexFields::ADMIN_SET_FACET, label: 'Collection Group', helper_method: 'admin_set_full_name', limit: 9999
    config.add_facet_field Ddr::IndexFields::COLLECTION_FACET, label: 'Collection', helper_method: 'collection_title', limit: 9999

    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!
    #use this instead if you don't want to query facets marked :show=>false
    #config.default_solr_params[:'facet.field'] = config.facet_fields.select{ |k, v| v[:show] != false}.keys

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    config.add_index_field solr_name(:creator, :stored_searchable), separator: '; ', label: 'Creator'
    config.add_index_field solr_name(:date, :stored_searchable), separator: '; ', label: 'Date'
    config.add_index_field solr_name(:type, :stored_searchable), separator: '; ', label:'Type'
    config.add_index_field Ddr::IndexFields::PERMANENT_URL, helper_method: 'permalink', label: 'Permalink'
    config.add_index_field Ddr::IndexFields::MEDIA_TYPE, helper_method: 'file_info', label: 'File'
    config.add_index_field Ddr::IndexFields::IS_PART_OF, helper_method: 'descendant_of', label: 'Part of'
    config.add_index_field Ddr::IndexFields::IS_MEMBER_OF_COLLECTION, helper_method: 'descendant_of', label: 'Collection'
    config.add_index_field Ddr::IndexFields::COLLECTION_URI, helper_method: 'descendant_of', label: 'Collection'

    config.default_document_solr_params = {
      fq: ["#{Ddr::IndexFields::WORKFLOW_STATE}:published"]
    }

    # partials for show view
    config.show.partials = [:show_header, :show, :show_license, :show_children]

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
    config.add_show_field Ddr::IndexFields::PERMANENT_URL, helper_method: 'permalink', label: 'Permalink'
    config.add_show_field Ddr::IndexFields::MEDIA_TYPE, helper_method: 'file_info', label: 'File'
    config.add_show_field solr_name(:creator, :stored_searchable), separator: '; ', label: 'Creator'
    config.add_show_field solr_name(:date, :stored_searchable), separator: '; ', label: 'Date'
    config.add_show_field solr_name(:type, :stored_searchable), separator: '; ', label: 'Type'
    (Ddr::Vocab::Vocabulary.term_names(RDF::DC) - [ :title, :creator, :date, :type ]).each do |term_name|
      config.add_show_field solr_name(term_name, :stored_searchable), separator: '; ', label: term_name.to_s.titleize
    end
    Ddr::Vocab::Vocabulary.term_names(Ddr::Vocab::DukeTerms).each do |term_name|
      config.add_show_field solr_name(term_name, :stored_searchable), separator: '; ', label: term_name.to_s.titleize
    end
    config.add_show_field Ddr::IndexFields::IS_PART_OF, helper_method: 'descendant_of', label: 'Part of'
    config.add_show_field Ddr::IndexFields::IS_MEMBER_OF_COLLECTION, helper_method: 'descendant_of', label: 'Collection'
    config.add_show_field Ddr::IndexFields::COLLECTION_URI, helper_method: 'descendant_of', label: 'Collection'

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
        :qf => "id title_tesim creator_tesim subject_tesim description_tesim identifier_tesim #{Ddr::IndexFields::PERMANENT_ID}"
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
    config.add_sort_field "#{Ddr::IndexFields::TITLE} asc", :label => 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Maximum number of results to show per page
    config.max_per_page = 999
  end

  def include_only_published(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "#{Ddr::IndexFields::WORKFLOW_STATE}:published"
  end

  def configure_blacklight_for_children
    blacklight_config.configure do |config|
      config.sort_fields.clear
      config.add_sort_field "#{Ddr::IndexFields::TITLE} asc", label: "Title"
      config.add_sort_field "#{Ddr::IndexFields::IDENTIFIER} asc", label: "Identifier"
    end
  end

  protected

  def forbidden
    render :file => "#{Rails.root}/public/403", :formats => [:html], :status => 403, :layout => false
  end

end
