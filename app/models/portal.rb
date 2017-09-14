class Portal

  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Ddr::Public::Controller::SolrQueryConstructor


  attr_accessor :local_id, :controller_name, :controller_scope

  def initialize(args={})
    @local_id         = args.fetch(:local_id, nil)
    @controller_name  = args.fetch(:controller_name, nil)
    @controller_scope = args.fetch(:controller_scope, nil)
  end


  private


  def item_or_collection_documents(local_ids)
    local_ids ? item_or_collection_documents_search(local_ids).documents : []
  end



  def parent_collection_uris
    @parent_collection_uris ||= parent_collection_documents.map { |document| document.internal_uri }
  end

  def parent_collection_document
    @parent_collection_document ||= parent_collection_documents.first if parent_collection_documents.count == 1
  end

  def parent_collection_documents
    @parent_collection_documents ||= parent_collections_search.documents || []
  end

  def parent_collections_count
    @parent_collections_count ||= parent_collections_search.total
  end

  def parent_collections_search
    query = search_builder.where(parent_collections_query).merge({rows: '1000'})
    @parent_collections_search ||= repository.search(query)
  end

  def parent_collections_query
    @parent_collections_query ||= portal_local_ids ? local_ids_query(portal_local_ids) : admin_set_query(portal_admin_sets)
  end



  def child_item_documents
    @child_item_documents ||= child_items_search.documents || []
  end

  def child_items_count
    @child_items_count ||= child_items_search.total
  end

  def child_items_search
    query = search_builder.where(child_items_query).merge({rows: '100', sort: solr_sort})
    @child_items_search ||= repository.search(query)
  end

  def child_items_query
    "(#{children_query(parent_collection_uris)}) AND #{active_fedora_model_query(['Item'])}"
  end



  def item_or_collection_documents_query(local_ids)
    "(#{local_ids_query(local_ids)}) AND (#{active_fedora_model_query(['Item', 'Collection'])})"
  end

  def item_or_collection_documents_search(local_ids)
    query = search_builder.where(item_or_collection_documents_query(local_ids)).merge({rows: '100', sort: solr_sort})
    repository.search(query)
  end

  def solr_sort
    "score desc, #{Ddr::Index::Fields::DATE_SORT} asc, #{Ddr::Index::Fields::TITLE} asc"
  end


  def search_builder
    @search_builder ||= SearchBuilder.new(query_processor_chain, @controller_scope)
  end

  def query_processor_chain
    [:add_query_to_solr, :apply_access_controls, :include_only_published]
  end

  def portal_admin_sets
    portal_view_config.try(:[], 'includes').try(:[], 'admin_sets')
  end

  def portal_local_ids
    portal_view_config.try(:[], 'includes').try(:[], 'local_ids')
  end

  def portal_view_config
    [local_id_configuration, dc_generic_view_config, controller_name_configuration].compact.first
  end

  def local_id_configuration
   portal_configuration.try(:[], local_id)
  end

  def controller_name_configuration
    portal_configuration.try(:[], controller_name)
  end

  def portal_configuration
    Rails.application.config.portal.try(:[], 'controllers')
  end

  def dc_generic_view_config
    if local_id && controller_name == 'digital_collections'
      { "includes"=>{ "local_ids"=>[local_id] } }
    end
  end


end
