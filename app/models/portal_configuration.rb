# :generic_configurations????

class PortalConfiguration
  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include Ddr::Public::Controller::SolrQueryConstructor

  attr_accessor :local_id, #This only works for collection local ids
                :controller_name,
                :showcase_custom_images,
                :features,
                :portal_view_config,
                :admin_sets,
                :local_ids,
                :restrictions,
                :blog_posts_url,
                :alert_message,
                :derivative_url_prefixes,
                :item_relators,
                :configure_blacklight,
                :child_items,
                :parent_collections,
                :parent_collection_uris,
                :view_path


  def initialize(args)
    @local_id        = args.fetch(:local_id, nil)
    @controller_name = args.fetch(:controller_name, nil)
  end


  # TODO: combine with features.showcase.documents
  #       after view/helper is refactored
  def showcase_custom_images
    portal_view_config.try(:[], 'showcase_images').try(:[], 'custom_images') || []
  end

  def features
    PortalFeatures.new(showcase, highlights, featured_collections, items)
  end

  def restrictions
    Restrictions.new(max_download)
  end

  def blog_posts_url
    portal_view_config.try(:[], 'blog_posts')
  end

  def alert_message
    portal_view_config.try(:[], 'alert')
  end

  def derivative_url_prefixes
    portal_view_config.try(:[], 'derivative_url_prefixes')
  end

  def item_relators
    portal_view_config.try(:[], 'item_relators')
  end

  def configure_blacklight
    portal_view_config.try(:[], 'configure_blacklight')
  end

  def child_items
    Documents.new(child_item_documents, child_items_count)
  end

  def parent_collections
    Documents.new(parent_collection_documents, parent_collections_count)
  end

  def parent_collection_uris
    @parent_collection_uris ||= parent_collection_documents.map { |document| document.internal_uri }
  end

  def view_path
    "app/views/ddr-portals/#{local_id || controller_name}"
  end


  private

  PortalFeatures = Struct.new(:showcase, :highlights, :collections, :items)
  Feature = Struct.new(:documents, :layout, :limit)
  Restrictions = Struct.new(:max_download)
  Documents = Struct.new(:documents, :count)

  def max_download
    portal_view_config.try(:[], 'restrictions').try(:[], 'max_download')
  end

  def showcase
    Feature.new(showcase_documents, showcase_layout, nil)
  end

  def highlights
    Feature.new(highlight_documents, nil, highlight_limit)
  end

  def featured_collections
    Feature.new(featured_collection_documents, nil, nil)
  end

  def items
    Feature.new(child_items.documents, nil, show_items)
  end

  def showcase_local_ids
    portal_view_config.try(:[], 'showcase_images').try(:[], 'local_ids')
  end

  def showcase_documents
    @showcase_documents ||= item_or_collection_documents(showcase_local_ids).concat showcase_custom_images
  end

  def showcase_layout
    portal_view_config.try(:[], 'showcase_images').try(:[], 'layout')
  end

  def highlight_local_ids
    portal_view_config.try(:[], 'highlight_images').try(:[], 'local_ids')
  end

  def highlight_documents
    @highlight_documents ||= item_or_collection_documents(highlight_local_ids)
  end

  def highlight_limit
    portal_view_config.try(:[], 'highlight_images').try(:[], 'display')
  end

  def featured_collection_documents
    @featured_collection_documents ||= item_or_collection_documents(featured_collections_local_ids)
  end

  def featured_collections_local_ids
    portal_view_config.try(:[], 'featured_collections').try(:[], 'local_ids')
  end

  def show_items
    portal_view_config.try(:[], 'show_items')
  end

  def child_item_documents
    @child_item_documents ||= documents(child_items_search) || []
  end

  def child_items_count
    @child_items_count ||= response(child_items_search).total
  end

  def child_items_search
    response, documents = get_search_results({ q: child_items_query, rows: 100 }, include_only_published)
  end

  def child_items_query
    "(#{children_query(parent_collection_uris)}) AND #{active_fedora_model_query(['Item'])}"
  end

  def parent_collection_documents
    @parent_collection_documents ||= documents(parent_collections_search) || []
  end

  def parent_collections_count
    @parent_collections_count ||= response(parent_collections_search).total
  end

  def parent_collections_search
    response, documents = get_search_results({ q: parent_collections_query, rows: 100 }, include_only_published)
  end

  def parent_collections_query
    portal_local_ids ? local_ids_query(portal_local_ids) : admin_set_query(portal_admin_sets)
  end

  def item_or_collection_documents(local_ids)
    local_ids ? documents(item_or_collection_documents_search(local_ids)) : []
  end

  def item_or_collection_documents_query(local_ids)
    "(#{local_ids_query(local_ids)}) AND (#{active_fedora_model_query(['Item', 'Collection'])})"
  end

  def item_or_collection_documents_search(local_ids)
    response, documents = get_search_results( { q: item_or_collection_documents_query(local_ids), rows: 25 }, include_only_published)
  end

  def response(response_and_documents)
    response_and_documents[0]
  end

  def documents(response_and_documents)
    response_and_documents[1]
  end

  def include_only_published
    { fq: "#{Ddr::Index::Fields::WORKFLOW_STATE}:published" }
  end

  def portal_admin_sets
    portal_view_config.try(:[], 'includes').try(:[], 'admin_sets')
  end

  def portal_local_ids
    portal_view_config.try(:[], 'includes').try(:[], 'local_ids')
  end

  def portal_view_config
    Rails.application.config.portal.try(:[], 'controllers').try(:[], local_id || controller_name)
  end

end
