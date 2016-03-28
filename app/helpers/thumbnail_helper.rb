module ThumbnailHelper

  def render_thumbnail_link document, size, counter = nil
    if multires_thumbnail_image_file_path = multires_thumbnail_image_file_path(document)
      multires_thumbnail_link_to_document(document, multires_thumbnail_image_file_path, size, counter)
    elsif collection_thumbnail_custom_image = collection_thumbnail_custom_image(document)
      image_tag = image_tag("ddr-portals/#{document.local_id}/#{collection_thumbnail_custom_image}", class: 'img-thumbnail', alt: 'Thumbnail')
      link_to_document document, image_tag, :counter => counter
    else
      render_thumbnail_tag(document, {}, :counter => counter)
    end 
  end

  def multires_thumbnail_image_file_path(document)
    multires_thumbnail_path = nil
    collection_item_documents = collection_thumbnail_item_documents(document)

    if collection_thumbnail_local_id(document) and collection_item_documents.length > 0
      multires_thumbnail_path = collection_item_documents.first.multires_image_file_paths.first
    elsif document.multires_image_file_path.present?
      multires_thumbnail_path = document.multires_image_file_path
    elsif document.multires_image_file_paths.present?
      multires_thumbnail_path = document.multires_image_file_paths.first
    end

    multires_thumbnail_path
  end

  def collection_thumbnail_item_documents(document)
    thumbnail_documents = []
    if thumbnail_local_id = collection_thumbnail_local_id(document)
      response, thumbnail_documents = get_search_results({:q => "(#{Ddr::Index::Fields::LOCAL_ID}:#{thumbnail_local_id}) AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item"})
    end
    thumbnail_documents
  end

  def collection_thumbnail_local_id(document)
    Rails.application.config.portal.try(:[] , 'portals').try(:[] , 'collection_local_id').try(:[] , document.local_id).try(:[] , 'thumbnail_image').try(:[] , 'local_id')
  end

  def collection_thumbnail_custom_image(document)
    Rails.application.config.portal.try(:[] , 'portals').try(:[] , 'collection_local_id').try(:[] , document.local_id).try(:[] , 'thumbnail_image').try(:[] , 'custom_image')
  end

  def multires_thumbnail_link_to_document(document, multires_image_file_path, size, counter)
    image_tag = iiif_image_tag(multires_image_file_path, {:size => size, :alt => 'Thumbnail', :class => 'img-thumbnail'})
    link_to_document document, image_tag, :counter => counter
  end

  def thumbnail_image_tag document, image_options = {}
    src = document.has_thumbnail? && can?(:read, document) ? thumbnail_path(document) : default_thumbnail(document)
    thumbnail = image_tag(src, :alt => "Thumbnail", :class => "img-thumbnail", size: "100x100")
  end

  def collection_thumbnail_image_path document, image_options = {}
    if multires_thumbnail_image_file_path = multires_thumbnail_image_file_path(document)
      iiif_image_path(multires_thumbnail_image_file_path, { :size => "!350,350", :region => 'pct:5,5,90,90' } )
    else
      src = document.has_thumbnail? && can?(:read, document) ? thumbnail_path(document) : default_thumbnail(document)
    end
  end

  def default_thumbnail(doc_or_obj)
    if doc_or_obj.has_content?
      default_mime_type_thumbnail(doc_or_obj.content_type)
    elsif doc_or_obj.display_format
      default_display_format_thumbnail(doc_or_obj.display_format)
    else
      default_model_thumbnail(doc_or_obj.active_fedora_model)
    end
  end

  private

  def default_mime_type_thumbnail(mime_type)
    case mime_type
    when /^image/
      'ddr-icons/image.png'
    when /^video/
      'ddr-icons/video.png'
    when /^audio/
      'ddr-icons/audio.png'
    when /^application\/(x-)?pdf/
      'ddr-icons/pdf.png'
    when /^application/
      'ddr-icons/binary.png'
    when /^text\/comma-separated-values/
      'ddr-icons/csv.png'
    else
      'ddr-icons/default.png'
    end
  end

  def default_display_format_thumbnail(display_format)
    case display_format
    when 'multi_image'
      'ddr-icons/image.png'
    when 'image'
      'ddr-icons/image.png'
    when 'video'
      'ddr-icons/video.png'
    when 'audio'
      'ddr-icons/audio.png'
    when 'collection'
      'ddr-icons/multiple.png'
    else
      'ddr-icons/default.png'
    end
  end

  def default_model_thumbnail(model)
    case model
    when 'Collection'
      'ddr-icons/multiple.png'
    else
      'ddr-icons/default.png'
    end
  end

end
