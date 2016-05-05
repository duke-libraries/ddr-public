
# TODO: Maybe this just provides an interface to the configurations
#       For SolrDocument...too repetitious? 

class SolrDocumentConfiguration
  
  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include Ddr::Public::Controller::SolrQueryConstructor
  
  attr_accessor :local_id, 
                :controller_name,
                :public_action,
                :public_collection,
                :public_controller,
                :public_id,
                :public_id_field,
                :thumbnail,
                :admin_policy_pid,
                :collection_document,
                :parent_collection_document,
                :collection_search_results,
                :parent_collection_search_results,
                :parent_collection_document_config

  def initialize(args)
    @local_id = args.fetch(:local_id, nil)
  end

  def public_action
    # TODO: Here or SolrDocument?
  end

  def public_collection
    parent_collection_document_config['collection']
  end

  def public_controller
    parent_collection_document_config['controller']
  end

  def public_id
    # TODO: Here or SolrDocument?
  end

  def public_id_field
    parent_collection_document_config['item_id_field']
  end

  def thumbnail
    parent_collection_document_config['thumbnail_image']
  end

  def admin_policy_pid
    parent_collection_document.admin_policy_pid
  end

  def parent_collection_document
    response, documents = parent_collection_search_results
    @parent_collection_document ||= documents.first
  end

  def collection_document
    response, documents = collection_search_results
    @collection_document ||= documents.first
  end

  def collection_search_results
    query = "#{local_ids_query([local_id])} AND (#{active_fedora_model_query(['Collection', 'Item'])})"
    @collection_search_results ||= get_solr_search_results( { q: query} )
  end

  def parent_collection_search_results
    query = ActiveFedora::SolrService.construct_query_for_pids([collection_document.admin_policy_pid])
    @parent_collection_search_results ||= get_solr_search_results( { q: query} )
  end

  def parent_collection_document_config
    parent_local_id = parent_collection_document.local_id
    Rails.application.config.portal.try(:[], 'portals').try(:[], 'collection_local_id').try(:[], parent_local_id)
  end

end
