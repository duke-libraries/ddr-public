module StreamingHelper

  # Temporarily account for manually configured AV derivative locations
  # until all can be migrated to DDR

  def stream_urls document
    if derivative_urls(document).present?
      derivative_urls(document) # legacy non-DDR derivatives
    else
      document.media_paths # streamable media derivatives in DDR
    end
  end

  def jwplayer_locals options={}
    case options[:media_mode]
      when 'audio'
        options[:height] = '40'
      when 'video'
        options[:aspectratio] = '4:3'
    end
    locals = {
      derivatives: options[:derivatives],
      width: options[:width] ||= '100%',
      height: options[:height],
      aspectratio: options[:aspectratio],
      media_type: options[:media_type],
      media_mode: options[:media_mode]
    }
    locals
  end

  def media_mode mimetype
    case mimetype
      when /^(audio\/)/
        'audio'
      when 'application/mp4',/^(video\/)/
        'video'
      else
        'unknown'
    end
  end

end
