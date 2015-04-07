module ApplicationHelper

  # Overrides corresponding method in Blacklight::FacetsHelperBehavior
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    if solr_field == Ddr::IndexFields::IS_MEMBER_OF_COLLECTION
      # apply custom sort for 'Collection' facet
      items = collection_facet_sort(paginator.items)
    else
      items = paginator.items
    end
    safe_join(items.
      map { |item| render_facet_item(solr_field, item) }.compact.
      map { |item| content_tag(wrapping_element,item)}
    )
  end

  # Custom sort for 'Collection' facet
  # Sort by title of collection normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the collection URI
  # The #collection_title method is defined in CatalogHelper and is also the view helper for the facet field
  def collection_facet_sort(items=[])
    items.sort { |a,b| collection_title(a.value).downcase <=> collection_title(b.value).downcase }
  end

  def alert_messages
    session[:alert_messages] ||= Ddr::Alerts::Message.active.pluck(:message)
  end

  def thumbnail_image_tag document, image_options = {}
    src = document.has_thumbnail? && can?(:read, document) ? thumbnail_path(document) : default_thumbnail(document)
    thumbnail = image_tag(src, :alt => "Thumbnail", :class => "img-thumbnail", size: "100x100")
  end

  def default_thumbnail(doc_or_obj)
    if doc_or_obj.has_content?
      default_mime_type_thumbnail(doc_or_obj.content_type)
    else
      default_model_thumbnail(doc_or_obj.active_fedora_model)
    end
  end

  def default_mime_type_thumbnail(mime_type)
    case mime_type
    when /^image/
      'crystal-clear/image2.png'
    when /^video/
      'crystal-clear/video.png'
    when /^audio/
      'crystal-clear/sound.png'
    when /^application\/(x-)?pdf/
      'crystal-clear/document.png'
    when /^application/
      'crystal-clear/binary.png'
    else
      'crystal-clear/misc.png'
    end
  end

  def default_model_thumbnail(model)
    case model
    when 'Collection'
      'crystal-clear/kmultiple.png'
    else
      'crystal-clear/misc.png'
    end
  end

  def staff_url(doc_or_obj)
    "#{Ddr::Public.staff_app_url}id/#{doc_or_obj.permanent_id}"
  end

end
