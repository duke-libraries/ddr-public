class PortalController < CatalogController
  include Ddr::Public::Controller::PortalSetup

  # Action exists to distinguish between the admin set
  # scoped portal/:collection and the portal/ route
  # This is for the portal/ page
  def index_portal
    index
  end

end
