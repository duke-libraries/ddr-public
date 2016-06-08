module ThumbnailHelper

  def render_thumbnail_link document, size, counter = nil
    link_to_document document, thumbnail_image_tag(document, {}), :counter => counter
  end

  def thumbnail_image_tag document, image_options = {}
    image_tag(thumbnail_path(document), :alt => "Thumbnail", :class => "img-thumbnail", size: "175x175")
  end

  def thumbnail_path document
    Thumbnail.new({ document: document, read_permission: can?(:read, document) }).thumbnail_path
  end

  def default_thumbnail_path document
    Thumbnail::Default.new({ document: document }).thumbnail_path
  end

  def multires_thumbnail_path document
    Thumbnail::MultiresItem.new({ document: document }).thumbnail_path
  end

end
