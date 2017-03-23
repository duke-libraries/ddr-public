class Thumbnail::MultiresComponent

  include Ddr::Public::Controller::IiifImagePaths

  attr_accessor :document, :size, :region


  def initialize(args)
    @document = args.fetch(:document, nil)
    @size     = args.fetch(:size, '!350,350')
    @region   = args.fetch(:region, 'full')
  end


  def has_thumbnail?
    component_multires_image_file_path?
  end

  def thumbnail_path
    if component_multires_image_file_path?
      iiif_image_path(component_multires_image_file_path, { size: size, region: region })
    end
  end


  private

  def component_multires_image_file_path?
    component_multires_image_file_path.present?
  end

  def component_multires_image_file_path
    document.multires_image_file_path
  end

end
