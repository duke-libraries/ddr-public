module ThumbnailHelper

  def render_thumbnail_link document, size, counter = nil
    link_to_document document, thumbnail_image_tag(document, {}), :counter => counter
  end

  def thumbnail_image_tag document, image_options = {}
    image_tag(thumbnail_path(document), :alt => "Thumbnail", :class => "img-thumbnail", size: "175x175")
  end

  def thumbnail_path document
    read_permission = can?(:read, document)
    Rails.cache.fetch("#{document.id}/#{read_permission}}/thumbnail_path", expires_in: 7.days) do
      Thumbnail.new({ document: document, read_permission: read_permission }).thumbnail_path
    end
  end

  def thumbnail_icon? document
    thumbnail_path(document).start_with?("ddr-icons/")
  end

  def default_thumbnail_path document
    Thumbnail::Default.new({ document: document }).thumbnail_path
  end

  def multires_thumbnail_path document
    Thumbnail::MultiresItem.new({ document: document }).thumbnail_path
  end

end
