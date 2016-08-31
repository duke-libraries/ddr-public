class ApplicationController < ActionController::Base

  cattr_accessor :current
  before_filter { ApplicationController.current = self }
  after_filter  { ApplicationController.current = nil  }

  helper Openseadragon::OpenseadragonHelper
  # Adds a few additional behaviors into the application controller
   include Blacklight::Controller
   include Ddr::Auth::RoleBasedAccessControlsEnforcement

  # Please be sure to impelement current_user and user_session. Blacklight depends on
  # these methods in order to perform user specific actions.

  layout 'blacklight'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

end
