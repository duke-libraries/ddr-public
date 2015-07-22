module ApplicationHelper

  # Overrides corresponding method in Blacklight::FacetsHelperBehavior
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    case solr_field
    when Ddr::IndexFields::ADMIN_SET_FACET
      # apply custom sort for 'admin set' facet
      items = admin_set_facet_sort(paginator.items)
    when Ddr::IndexFields::COLLECTION_FACET
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

  # Custom sort for 'admin set' facet
  # Sort by full name of admin set normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the admin set slug
  # The #admin_set_full_name method is defined in ModelsHelper in ddr-models and is also the view helper for the facet field
  def admin_set_facet_sort(items=[])
    items.sort { |a,b| admin_set_full_name(a.value).downcase <=> admin_set_full_name(b.value).downcase }
  end

  # Custom sort for 'Collection' facet
  # Sort by title of collection normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the collection URI
  # The #collection_title method is defined in CatalogHelper and is also the view helper for the facet field
  def collection_facet_sort(items=[])
    items.sort { |a,b| collection_title(a.value).downcase <=> collection_title(b.value).downcase }
  end

  def alert_messages
    Ddr::Alerts::Message.active.pluck(:message)
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

  # Build IIIF image tags for image files served by IIP Image Server

  def iiif_image_path(filepath,options)
    size = options[:size] ? options[:size] : 'full'
    region = options[:region] ? options[:region] : 'full'
    url = "#{Ddr::Models.image_server_url}?IIIF=#{filepath}/#{region}/#{size}/0/default.jpg"
  end
  
  def iiif_image_info_path(filepath)
    url = "#{Ddr::Models.image_server_url}?IIIF=#{filepath}/info.json"    
  end

  def iiif_image_tag(filepath,options)
    url = iiif_image_path(filepath,options)
    image_tag url, :alt => options[:alt].presence, :class => options[:class].presence
  end

  def url_for_document doc, options = {}
    if respond_to?(:blacklight_config) and
        blacklight_config.show.route
      route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
      route[:controller] = controller_name if route[:controller] == :current
      route
    else
      doc
    end
  end

end
