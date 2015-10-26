# -*- encoding : utf-8 -*-
class WdukesonsController < DigitalCollectionsController
  include Ddr::Public::Controller::PortalControllerConfig
  
  def about
    render 'about'
  end

  configure_blacklight do |config|

    # Set Facet configurations
    config.facet_fields.clear
    config.add_facet_field Ddr::Index::Fields::ACTIVE_FEDORA_MODEL.to_s, label: "Browse", show: false
    config.add_facet_field Ddr::Index::Fields::SERIES_FACET.to_s, label: "Card Series", collapse: false, limit: 5
    config.add_facet_field Ddr::Index::Fields::YEAR_FACET.to_s, label: 'Year', collapse: false, limit: 9999, :range => {
      :num_segments => 6,
      :segments => true
    }    
    config.add_facet_field Ddr::Index::Fields::TYPE_FACET.to_s, label: "Type", limit: 5    
    config.add_facet_field Ddr::Index::Fields::PUBLISHER_FACET.to_s, label: "Publisher", limit: 5
    config.add_facet_field Ddr::Index::Fields::SPATIAL_FACET.to_s, label: "Location", limit: 5
    config.add_facet_field Ddr::Index::Fields::BOX_NUMBER_FACET.to_s, sort: 'index', label: "Box Number", limit: 5

    
    # Set Show metadata
    config.show_fields.clear
    config.add_show_field solr_name(:title, :stored_searchable), separator: '; ', label: 'Title'
    config.add_show_field Ddr::Index::Fields::PERMANENT_URL.to_s, helper_method: 'permalink', label: 'Permalink'
    config.add_show_field Ddr::Index::Fields::IS_PART_OF.to_s, helper_method: 'descendant_of', label: 'Part of'
    config.add_show_field Ddr::Index::Fields::IS_MEMBER_OF_COLLECTION.to_s, helper_method: 'descendant_of', label: 'Collection'
    config.add_show_field Ddr::Index::Fields::COLLECTION_URI.to_s, helper_method: 'descendant_of', label: 'Collection'

    config.add_show_field solr_name(:series, :stored_searchable), separator: '; ', label: "Card Series", link_to_search: Ddr::Index::Fields::SERIES_FACET.to_s
    config.add_show_field solr_name(:type, :stored_searchable), separator: "; ", label: "Type", link_to_search: Ddr::Index::Fields::TYPE_FACET
    config.add_show_field solr_name(:spatial, :stored_searchable), separator: "; ", label: "Location", link_to_search: Ddr::Index::Fields::SPATIAL_FACET
    config.add_show_field solr_name(:publisher, :stored_searchable), separator: "; ", label: "Publisher", link_to_search: Ddr::Index::Fields::PUBLISHER_FACET
    config.add_show_field solr_name(:date, :stored_searchable), separator: "; ", helper_method: "year_ranges", label: "Year"
    config.add_show_field solr_name(:language, :stored_searchable), separator: "; ", helper_method: "language_display", label: "Language"

    config.add_show_field Ddr::Index::Fields::EAD_ID.to_s, separator: "; ", helper_method: 'source_collection', label: "Source Collection"
    config.add_show_field solr_name(:box_number, :stored_searchable), separator: "; ", label: "Box Number"
    config.add_show_field solr_name(:extent, :stored_searchable), separator: "; ", label: "Extent"

  end

end