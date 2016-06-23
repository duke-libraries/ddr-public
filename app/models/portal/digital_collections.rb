class Portal::DigitalCollections < Portal

  def collection
    parent_collection_document
  end

  def collections
    parent_collection_documents
  end

  def collection_count
    parent_collections_count
  end

  def items
    child_item_documents
  end

  def item_count
    child_items_count
  end

  def title
    parent_collection_document ? parent_collection_document.title : configured_title
  end

  def abstract
    parent_collection_document.abstract
  end

  def description
    parent_collection_document.description
  end

  def ead_id
    parent_collection_document.ead_id
  end

  def showcase
    Showcase.new(showcase_documents, showcase_layout)
  end

  def item_highlights
    Highlight.new(highlight_documents, highlight_limit)
  end

  def collection_highlights
    Highlight.new(featured_collection_documents, nil)
  end

  def show_items
    portal_view_config.try(:[], 'show_items')
  end

  # TODO: combine with features.showcase.documents
  #       after view/helper is refactored
  def showcase_custom_images
    portal_view_config.try(:[], 'showcase_images').try(:[], 'custom_images') || []
  end

  def blog_posts_url
    portal_view_config.try(:[], 'blog_posts')
  end

  def alert_message
    portal_view_config.try(:[], 'alert')
  end


  private

  Showcase = Struct.new(:documents, :layout)
  Highlight = Struct.new(:documents, :limit)

  def showcase_layout
    portal_view_config.try(:[], 'showcase_images').try(:[], 'layout')
  end

  def showcase_documents
    @showcase_documents ||= item_or_collection_documents(showcase_local_ids)
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

  def showcase_local_ids
    portal_view_config.try(:[], 'showcase_images').try(:[], 'local_ids')
  end


end
