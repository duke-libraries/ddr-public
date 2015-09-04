# -*- encoding : utf-8 -*-
class BlakeController < DigitalCollectionsController
  include Ddr::Public::Controller::PortalControllerConfig
  
  def about
    render 'about'
  end

  configure_blacklight do |config|
    config.facet_fields.clear
    config.add_facet_field Ddr::IndexFields::TYPE_FACET.to_s, label: "Type", collapse: false, sort: 'index'
  end

end