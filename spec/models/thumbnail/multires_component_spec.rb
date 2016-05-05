require 'spec_helper'

RSpec.describe Thumbnail::MultiresComponent do

  describe "multires component thumbnail" do

    it "has a multires image" do
      document = double("Document")
      allow(document).to receive(:multires_image_file_path) { '/path/to/image/' }
      custom = Thumbnail::MultiresComponent.new({document: document})
      expect(custom.has_thumbnail?).to eq true
    end

    it "has a multires image path" do
      document = double("Document")
      allow(document).to receive(:multires_image_file_path) { '/path/to/image' }
      custom = Thumbnail::MultiresComponent.new({document: document})
      expect(custom.thumbnail_path).to include '=/path/to/image/full/!350,350/0/default.jpg'
    end

    it "does not have a multires image" do
      document = double("Document")
      allow(document).to receive(:multires_image_file_path) { nil }
      custom = Thumbnail::MultiresComponent.new({document: document})
      expect(custom.has_thumbnail?).to eq false
    end

  end

end
