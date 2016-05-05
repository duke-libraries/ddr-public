class Thumbnail::Selector

  attr_accessor :document, :size, :region, :read_permission


  def initialize(args)
    @document          = args.fetch(:document, nil)
    @size              = args.fetch(:size, '!350,350')
    @region            = args.fetch(:region, 'full')
    @read_permission   = args.fetch(:read_permission, false)
  end


  def thumbnail_path
    thumbnails.select { |thumbnail| thumbnail.has_thumbnail? }.first.thumbnail_path
  end


  private

  def thumbnails
    thumbnail_classes.map { |klass| klass.new({ document: document, size: size, region: region }) }
  end

  def thumbnail_classes
    read_permission? && configured_thumbnails ? configured_thumbnails : Array(default_thumbnails)
  end

  def configured_thumbnails
    if local_configuration
      thumbnails = local_configuration.split(/\W+/).map do |thumbnail|
        "Thumbnail::#{thumbnail}".safe_constantize
      end
      thumbnails.push default_thumbnails
    end
  end

  def default_thumbnails
    Thumbnail::Default
  end

  def read_permission?
    read_permission
  end

  def local_configuration
    Ddr::Public.thumbnails
  end

end
