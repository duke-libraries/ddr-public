class Thumbnail::CustomCollection

  attr_accessor :document


  def initialize(args)
    @document = args.fetch(:document, nil)
  end


  def has_thumbnail?
    custom_thumbnail_file_name?
  end

  def thumbnail_path
    "ddr-portals/#{document.local_id}/#{custom_thumbnail_file_name}" if custom_thumbnail_file_name?
  end


  private

  def custom_thumbnail_file_name?
    custom_thumbnail_file_name ? true : false
  end

  def custom_thumbnail_file_name
    document.thumbnail.try(:[], 'custom_image')
  end

end
