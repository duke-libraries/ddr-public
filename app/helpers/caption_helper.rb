module CaptionHelper

  require 'webvtt'

  def caption_contents caption_url
    caption_fullurl = File.join(root_url,caption_url)
    caption_file = open(caption_fullurl,"rb")
    
    if caption_file.is_a?(StringIO)
      # This happens when file is <10KB: it opens as a string. So write it back to a tmp file.
      tmp_vtt_file = Tempfile.new("ddr-vtt-#{Time.now.utc}")
      File.write(tmp_vtt_file.path, caption_file.string.force_encoding("UTF-8"))
      vtt = WebVTT.read(tmp_vtt_file)
    else
      vtt = WebVTT.read(caption_file)
    end

    return vtt

  end

  def clean_cue_text line
    text = Nokogiri::HTML(line).text
  end

  # Split cue into parts when there are intentional line breaks
  def cue_lines cue_text
    cue_text.split("\n")
  end

  def cue_speaker line
    # Regex instead of Nokogiri b/c <v Jane Done> not easily parsed w/xpath or css selectors
    match = /<v\s*([^>]*)>/.match(line)
    if match
      speaker = match[1]
      # Some transcripts only have <v -> to indicate speaker has changed, but
      # don't indicate speaker's name
      if ["","-"].include? speaker
        return raw("&mdash;")
      end
      speaker
    end
  end

  def display_time cue_time_sec
    if cue_time_sec < 3600
      Time.at(cue_time_sec).utc.strftime("%-M:%S")
    else
      Time.at(cue_time_sec).utc.strftime("%-H:%M:%S")
    end
  end

end
