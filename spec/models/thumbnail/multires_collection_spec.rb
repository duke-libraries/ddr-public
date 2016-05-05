require 'spec_helper'

RSpec.describe Thumbnail::MultiresCollection do

  describe "multires collection thumbnail" do

    it "does not have a thumbnail if not configured" do
      document = double("Document")
      allow(document).to receive (:thumbnail) { {} }
      multires_collection = Thumbnail::MultiresCollection.new({ document: document })
      expect(multires_collection.has_thumbnail?).to eq false
    end

  end

end
