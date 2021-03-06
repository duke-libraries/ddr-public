module CaptionHelper

  require 'webvtt'

  def caption_contents captions_path
    caption_file = File.open(captions_path,"r")

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
        return "-"
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

  def caption_text_from_vtt vtt
    caption_text = ""
    vtt.cues.each_with_index do |cue, cue_index|
      cue_lines(cue.text).each_with_index do |line, line_index|

        # keep any intentional line breaks within cues
        unless line_index == 0
          caption_text << "\n"
        end

        # Speaker change (<v>) gets double linebreak except in the very first cue
        if cue_speaker(line).present?
          unless cue_index == 0
            if line_index == 0
              caption_text << "\n\n"
            else
              #already got one linebreak, just need one more
              caption_text << "\n"
            end
          end

          # preface text with {speaker name}: if <v> is identified or just - if <v ->.
          caption_text << [cue_speaker(line), (cue_speaker(line) != "-" ? ": " : " ")].join("")
        end

        # combine cues with spaces.
        caption_text << [clean_cue_text(line)," "].join("")
      end
    end
    caption_text
  end

end
