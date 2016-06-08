require 'spec_helper'

RSpec.describe Thumbnail::CustomCollection do

  describe "custom thumbnail" do

    it "has a thumbnail if configured" do
      document = double("Document")
      allow(document).to receive(:local_id) { 'dukechapel' }
      allow(document).to receive(:thumbnail) { {'custom_image' => 'custom.jpg'} }
      custom = Thumbnail::CustomCollection.new({document: document})
      expect(custom.has_thumbnail?).to eq true
    end

    it "has a thumbnail path if configured" do
      document = double("Document")
      allow(document).to receive(:local_id) { 'dukechapel' }
      allow(document).to receive(:thumbnail) { {'custom_image' => 'custom.jpg'} }
      custom = Thumbnail::CustomCollection.new({document: document})
      expect(custom.thumbnail_path).to eq 'ddr-portals/dukechapel/custom.jpg'
    end

    it "does not have a thumbnail if not configured" do
      document = double("Document")
      allow(document).to receive(:local_id) { 'dukechapel' }
      allow(document).to receive(:thumbnail) { nil }
      custom = Thumbnail::CustomCollection.new({document: document})
      expect(custom.has_thumbnail?).to eq false
    end

  end

end
