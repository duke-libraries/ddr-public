module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def thumbnail_image_tag document, image_options = {}
    src = document.has_thumbnail? ? thumbnail_path(document) : default_thumbnail(document)
    thumbnail = image_tag(src, :alt => "Thumbnail", :class => "img-thumbnail")
  end

end