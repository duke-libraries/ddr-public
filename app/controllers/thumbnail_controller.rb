class ThumbnailController < ApplicationController

  include Hydra::Controller::DownloadBehavior

  def datastream_name
    "#{asset.pid.sub(/:/, "-")}-thumbnail"
  end

  def load_file # datastream_to_show
    asset.attached_files[Ddr::Models::File::THUMBNAIL]
  end

end
