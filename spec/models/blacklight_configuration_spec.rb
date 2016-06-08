require 'spec_helper'

RSpec.describe BlacklightConfiguration do

  context "configured with a controller_name" do
    it "configuration should return the local_id configuration" do
      Rails.application.config.portal = { 'controllers' => { 'wdukesons' => { 'configure_blacklight' => 'add_facet_field' } } }
      blacklight_configuration = BlacklightConfiguration.new({local_id: 'wdukesons'})
      expect(blacklight_configuration.configuration).to eq 'add_facet_field'
    end
  end

  context "configured with a controller_name" do
    it "configuration should return the local_id configuration" do
      Rails.application.config.portal = { 'controllers' => { 'digital_collections' => { 'configure_blacklight' => 'add_facet_field' } } }
      blacklight_configuration = BlacklightConfiguration.new({controller_name: 'digital_collections'})
      expect(blacklight_configuration.configuration).to eq 'add_facet_field'
    end
  end

  context "configured with a controller_name" do
    it "configuration should return the local_id configuration" do
      Rails.application.config.portal = { 'controllers' => { 'digital_collections' => { 'configure_blacklight' => 'add_facet_field' } } }
      blacklight_configuration = BlacklightConfiguration.new({controller_name: 'portal'})
      expect(blacklight_configuration.configuration).to eq nil
    end
  end


end