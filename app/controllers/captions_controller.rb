class CaptionsController < ApplicationController

before_action :enforce_show_permissions
include CaptionHelper

  def show
    asset = SolrDocument.find(params[:id])
    if asset.captionable?

      send_file asset.caption_path,
                type: asset.caption_type,
                stream: true,
                disposition: 'inline',
                filename: [asset.public_id, asset.caption_extension].join(".")
    else
      render nothing: true, status: 404
    end
  end

  def text
    asset = SolrDocument.find(params[:id])
    if asset.captionable?
      send_data caption_text_from_vtt(caption_contents(asset.captions_url)), filename: [asset.public_id,'txt'].join("."), type: 'text/plain', disposition: 'inline', stream: true
    else
      render nothing: true, status: 404
    end
  end

  def pdf
    asset = SolrDocument.find(params[:id])
    if asset.captionable?
      alltext = caption_text_from_vtt(caption_contents(asset.captions_url))
      permalink = asset.permanent_url

      pdf = Prawn::Document.new do

        # Registering a TTF font is needed to support UTF-8 character set
        font_families.update("SourceSansPro" => {
          :normal => Rails.root.join("app/assets/fonts/SourceSansPro-Regular.ttf"),
          :italic => Rails.root.join("app/assets/fonts/SourceSansPro-Italic.ttf"),
          :bold => Rails.root.join("app/assets/fonts/SourceSansPro-Bold.ttf"),
          :bold_italic => Rails.root.join("app/assets/fonts/SourceSansPro-BoldItalic.ttf")
        })
        default_leading 5

        font("SourceSansPro", :style => :bold) do
          text asset.html_title
          move_down 5
        end

        font("SourceSansPro") do

          text permalink
          move_down 15

          stroke do
            stroke_color '333333'
            line_width 2
            stroke_horizontal_rule
            move_down 15
          end

          text alltext
        end
      end

      send_data pdf.render, filename: [asset.public_id,'pdf'].join("."), type: 'application/pdf', disposition: 'inline', stream: true

    else
      render nothing: true, status: 404
    end
  end

end
