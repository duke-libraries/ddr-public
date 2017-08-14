class CaptionsController < ApplicationController

before_action :enforce_show_permissions

  def show
    asset = SolrDocument.find(params[:id])
    if asset.captionable?

      send_file asset.caption_path,
                type: asset.caption_type,
                filename: [asset.public_id, asset.caption_extension].join(".")
    else
      render nothing: true, status: 404
    end
  end

end
