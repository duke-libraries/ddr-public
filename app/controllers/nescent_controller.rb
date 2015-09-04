# -*- encoding : utf-8 -*-
class NescentController < CatalogController

  include Ddr::Public::Controller::PortalControllerConfig

  def about
    render 'about'
  end

  configure_blacklight do |config|
    config.facet_fields.clear
    config.add_facet_field Ddr::IndexFields::COLLECTION_FACET.to_s, label: 'Collection', helper_method: 'collection_title', limit: 9999, collapse: false 
  end

end
