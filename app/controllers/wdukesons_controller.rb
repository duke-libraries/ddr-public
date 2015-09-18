# -*- encoding : utf-8 -*-
class WdukesonsController < DigitalCollectionsController
  include Ddr::Public::Controller::PortalControllerConfig
  
  def about
    render 'about'
  end

  configure_blacklight do |config|
    config.facet_fields.clear
    config.add_facet_field Ddr::IndexFields::TYPE_FACET.to_s, label: "Type", collapse: false, limit: 5
    config.add_facet_field Ddr::IndexFields::YEAR_FACET.to_s, label: 'Year', collapse: false, limit: 9999, :range => {
      :num_segments => 6,
      :assumed_boundaries => [1889, 1935],
      :segments => true    
    }    
    config.add_facet_field Ddr::IndexFields::SERIES_FACET.to_s, label: "Series", limit: 5
    config.add_facet_field Ddr::IndexFields::PUBLISHER_FACET.to_s, label: "Publisher", limit: 5
    config.add_facet_field Ddr::IndexFields::SPATIAL_FACET.to_s, label: "Location", limit: 5
    config.add_facet_field Ddr::IndexFields::BOX_NUMBER_FACET.to_s, sort: 'index', label: "Box Number", limit: 5
  end

end