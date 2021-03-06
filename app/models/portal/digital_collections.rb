class Portal::DigitalCollections < Portal

  def collection
    @collection ||= parent_collection_document
  end

  def collections
    @collections ||= parent_collection_documents
  end

  def collection_count
    @collection_count ||= parent_collections_count
  end

  def items
    @items ||= child_item_documents
  end

  def item_count
    @item_count ||= child_items_count
  end

  def title
    @title ||= parent_collection_document.title
  end

  def abstract
    @abstract ||= parent_collection_document.abstract
  end

  def description
    @description ||= parent_collection_document.description
  end

  def ead_id
    @ead_id ||= parent_collection_document.ead_id
  end

  def showcase
    @showcase ||= Showcase.new(showcase_documents, showcase_layout)
  end

  def item_highlights
    @item_highlights ||= Highlight.new(highlight_documents, highlight_limit)
  end

  def collection_highlights
    @collection_highlights ||= Highlight.new(featured_collection_documents, nil)
  end

  def show_items
    portal_view_config.try(:[], 'show_items')
  end

  def showcase_custom_images
    portal_view_config.try(:[], 'showcase_images').try(:[], 'custom_images') || []
  end

  def showcase_images_all
    showcase_custom_images.concat showcase.documents
  end

  def blog_posts_url
    portal_view_config.try(:[], 'blog_posts')
  end

  def alert_message
    portal_view_config.try(:[], 'alert')
  end

  def html_title_context
    @html_title_context ||= parent_collection_document.present? ? parent_collection_document.title : 'Digital Collections'
  end

  private

  Showcase = Struct.new(:documents, :layout)
  Highlight = Struct.new(:documents, :limit)

  def showcase_layout
    portal_view_config.try(:[], 'showcase_images').try(:[], 'layout')
  end

  def showcase_documents
    item_or_collection_documents(showcase_local_ids)
  end

  def highlight_local_ids
    portal_view_config.try(:[], 'highlight_images').try(:[], 'local_ids')
  end

  def highlight_documents
    item_or_collection_documents(highlight_local_ids)
  end

  def highlight_limit
    portal_view_config.try(:[], 'highlight_images').try(:[], 'display')
  end

  def featured_collection_documents
    item_or_collection_documents(featured_collections_local_ids)
  end

  def featured_collections_local_ids
    portal_view_config.try(:[], 'featured_collections').try(:[], 'local_ids')
  end

  def showcase_local_ids
    portal_view_config.try(:[], 'showcase_images').try(:[], 'local_ids')
  end


end
