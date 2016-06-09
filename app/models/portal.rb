class Portal

  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include Ddr::Public::Controller::SolrQueryConstructor


  attr_accessor :local_id, :controller_name, :current_ability

  def initialize(args={})
    @local_id        = args.fetch(:local_id, nil)
    @controller_name = args.fetch(:controller_name, nil)
    @current_ability = args.fetch(:current_ability, nil)
  end


  private


  def item_or_collection_documents(local_ids)
    local_ids ? documents(item_or_collection_documents_search(local_ids)) : []
  end



  def parent_collection_uris
    @parent_collection_uris ||= parent_collection_documents.map { |document| document.id }
  end

  def parent_collection_document
    parent_collection_documents.first if parent_collection_documents.count == 1
  end

  def parent_collection_documents
    @parent_collection_documents ||= documents(parent_collections_search) || []
  end

  def parent_collections_count
    @parent_collections_count ||= response(parent_collections_search).total
  end

  def parent_collections_search
    response, documents = search_results({ q: parent_collections_query, rows: 100 }, query_processor_chain)
  end

  def parent_collections_query
    portal_local_ids ? local_ids_query(portal_local_ids) : admin_set_query(portal_admin_sets)
  end



  def child_item_documents
    @child_item_documents ||= documents(child_items_search) || []
  end

  def child_items_count
    @child_items_count ||= response(child_items_search).total
  end

  def child_items_search
    response, documents = search_results({ q: child_items_query, rows: 100 }, query_processor_chain)
  end

  def child_items_query
    "(#{children_query(parent_collection_uris)}) AND #{active_fedora_model_query(['Item'])}"
  end



  def item_or_collection_documents_query(local_ids)
    "(#{local_ids_query(local_ids)}) AND (#{active_fedora_model_query(['Item', 'Collection'])})"
  end

  def item_or_collection_documents_search(local_ids)
    response, documents = search_results( { q: item_or_collection_documents_query(local_ids), rows: 25 }, query_processor_chain)
  end



  def query_processor_chain
    [:add_query_to_solr, :apply_gated_discovery, :include_only_published]
  end



  def response(response_and_documents)
    response_and_documents[0]
  end

  def documents(response_and_documents)
    response_and_documents[1]
  end



  def portal_admin_sets
    portal_view_config.try(:[], 'includes').try(:[], 'admin_sets')
  end

  def portal_local_ids
    portal_view_config.try(:[], 'includes').try(:[], 'local_ids')
  end

  def portal_view_config
    portal_view_config = Rails.application.config.portal.try(:[], 'controllers').try(:[], local_id)
    portal_view_config ||= Rails.application.config.portal.try(:[], 'controllers').try(:[], controller_name)
  end


end
