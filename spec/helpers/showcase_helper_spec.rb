require 'rails_helper'

RSpec.describe ShowcaseHelper do

  describe "#home_showcase_locals" do
    context "the image is a filename" do
      let(:options) { { index: 1, image: 'chapel.png', showcase_layout: 'landscape'} }
      it "returns a hash with a path to the image" do
        expect(helper.home_showcase_locals(options)).to eq({index: 1, image: "chapel.png", size_class: "col-md-8 col-sm-12"})
      end
    end

    context "the image is a document" do
      let(:document) { SolrDocument.new( {'id'=>'changeme:10' } ) } 
      let(:options) {
        { index: 1,
          image: document,
          showcase_layout: 'portrait' }
      }
      it "returns a hash with a multires item document" do
        expect(helper.home_showcase_locals(options)).to eq({index: 1, image: document, size_class: "col-md-4 col-sm-6", size: "600,", region: "pct:5,5,90,90", caption_length: 50})
      end
    end

  end

end
