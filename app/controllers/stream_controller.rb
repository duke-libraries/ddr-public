class StreamController < ApplicationController

before_action :enforce_show_permissions

  def show
    asset = SolrDocument.find(params[:id])
    if asset.streamable?

      send_file asset.streamable_media_path,
                type: asset.streamable_media_type,
                stream: true,
                disposition: 'inline',
                filename: [asset.public_id, asset.streamable_media_extension].join(".")
    else
      render nothing: true, status: 404
    end
  end

end
