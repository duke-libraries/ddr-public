class Thumbnail::MultiresItem

  include Ddr::Public::Controller::IiifImagePaths

  attr_accessor :document, :size, :region


  def initialize(args)
    @document = args.fetch(:document, nil)
    @size     = args.fetch(:size, '!350,350')
    @region   = args.fetch(:region, 'full')
  end


  def has_thumbnail?
    item_multires_image_file_path?
  end

  def thumbnail_path
    iiif_image_path(item_multires_image_file_path, { size: size, region: region })
  end


  private

  def item_multires_image_file_path?
    item_multires_image_file_path ? true : false
  end

  def item_multires_image_file_path
    document.first_multires_image_file_path
  end

end
