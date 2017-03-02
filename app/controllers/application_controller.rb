class ApplicationController < ActionController::Base

  # Needed so that a SolrDocument can know about its
  # active controller scope. Any additional queries can then
  # use the same search builder context.
  cattr_accessor :current
  before_filter { ApplicationController.current = self }
  after_filter  { ApplicationController.current = nil  }

  before_action :sign_out,
                if: [:user_signed_in?, "Ddr::Auth.require_shib_user_authn"],
                unless: :shib_session?

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

  def shib_session?
    # This is how omniauth-shibboleth checks for a Shib session
    request.env['Shib-Session-ID'] || request.env['Shib-Application-ID']
  end

end
