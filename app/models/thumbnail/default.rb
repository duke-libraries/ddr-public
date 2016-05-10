class Thumbnail::Default
  
  attr_accessor :document


  def initialize(args)
    @document = args.fetch(:document, nil)
  end


  def has_thumbnail?
    default_thumbnail?
  end

  def thumbnail_path
    ENV['ROOT_URL'] ? "#{ENV['ROOT_URL']}/assets/#{default_thumbnail}" : default_thumbnail
  end


  private

  def default_thumbnail?
    default_thumbnail ? true : false
  end

  def default_thumbnail
    thumbnails.compact.first
  end

  def thumbnails
    [
      mime_type_thumbnail,
      display_format_thumbnail,
      active_fedora_model_thumbnail,
      fallback_thumbnail
    ]
  end

  def mime_type_thumbnail
    case document.content_type
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
    end
  end

  def display_format_thumbnail
    case document.display_format
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
    end
  end

  def active_fedora_model_thumbnail
    case document.active_fedora_model
    when 'Collection'
      'ddr-icons/multiple.png'
    end
  end

  def fallback_thumbnail
    'ddr-icons/default.png'
  end

end
