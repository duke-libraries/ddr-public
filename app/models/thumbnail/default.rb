class Thumbnail::Default

  attr_accessor :document


  def initialize(args)
    @document = args.fetch(:document, nil)
  end


  def has_thumbnail?
    default_thumbnail?
  end

  def thumbnail_path
    default_thumbnail if default_thumbnail?
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
    when /^(multipart|application)\/(x-)?g?zip.?/
      'ddr-icons/zip.png'
    when 'application/rtf'
      'ddr-icons/rtf.png'
    when 'application/postscript'
      'ddr-icons/postscript.png'
    when 'application/vnd.google-earth.kmz'
      'ddr-icons/kml.png'
    when 'application/vnd.google-earth.kml+xml'
      'ddr-icons/kml-xml.png'
    when 'application/x-sas'
      'ddr-icons/x-sas.png'
    when /^application\/(x-|vnd.)?(ms)?-?excel/
      'ddr-icons/xls.png'
    when 'application/vnd.openxmlformats-officedocument.spreadsheetml'
      'ddr-icons/xls.png'
    when /^application\/(x-|vnd.)?(ms)?-?powerpoint/
      'ddr-icons/ppt.png'
    when 'application/vnd.openxmlformats-officedocument.presentationml'
      'ddr-icons/ppt.png'
    when /^application\/msword/
      'ddr-icons/doc.png'
    when 'application/vnd.openxmlformats-officedocument.wordprocessingml'
      'ddr-icons/doc.png'
    when /^application\/(x-)?pdf/
      'ddr-icons/pdf.png'
    when /^application/
      'ddr-icons/binary.png'
    when 'message/rfc822'
      'ddr-icons/email.png'
    when 'text/html'
      'ddr-icons/html.png'
    when /^text\/(comma-separated-values|csv)/
      'ddr-icons/csv.png'
    when /^text\/.?/
      'ddr-icons/txt.png'
    end
  end

  def display_format_thumbnail
    case document.display_format
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
