module ThumbnailHelper

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

  private

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

end
