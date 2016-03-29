require 'rails_helper'

RSpec.describe ThumbnailHelper do

  describe "#thumbnail_image_tag" do
    context "the object has a thumbnail" do
      let(:document) { SolrDocument.new({
              'id'=>'changeme:10',
              'attached_files_ss'=>['{"thumbnail":{"size":14992},"content":{"size":24330280},"extractedText":{"size":null},"fits":{"size":4797}}']
              }) }
      context "user can read the document" do
        before { allow(helper).to receive(:can?).with(:read, document).and_return(true) }
        it "returns an image tag for the thumbnail" do
          expect(helper.thumbnail_image_tag(document)).to eq("<img alt=\"Thumbnail\" class=\"img-thumbnail\" height=\"100\" src=\"/thumbnail/changeme:10\" width=\"100\" />")
        end
      end
      context "user cannot read the document" do
        before { allow(helper).to receive(:can?).with(:read, document).and_return(false) }
        it "calls default_thumbnail" do
          expect(helper).to receive(:default_thumbnail).with(document)
          helper.thumbnail_image_tag(document)
        end
      end
    end
    context "the object does not have a thumbnail" do
      let(:document) { SolrDocument.new({
              'id'=>'changeme:10',
              'attached_files_ss'=>['{"content":{"size":24330280},"extractedText":{"size":null},"fits":{"size":4797}}']
              }) }
      it "calls default_thumbnail" do
        expect(helper).to receive(:default_thumbnail).with(document)
        helper.thumbnail_image_tag(document)
      end
    end
  end

  describe "#default_thumbnail" do
    context "object has content" do
      let(:document) { SolrDocument.new({
              'id'=>'changeme:10',
              'attached_files_ss'=>['{"content":{"size":24330280, "mime_type":"image/tiff"},"extractedText":{"size":null},"fits":{"size":4797}}']
              }) }
      it "should call default_mime_type_thumbnail" do
        expect(helper).to receive(:default_mime_type_thumbnail).with("image/tiff")
        helper.default_thumbnail(document)
      end
    end
    context "object does not have content" do
      let(:document) { SolrDocument.new({
              'active_fedora_model_ssi'=>'TestModel',
              'id'=>'changeme:10',
              'attached_files_ss'=>['{"content":{"size":null, "mime_type":"text/plain"},"extractedText":{"size":null},"fits":{"size":4797}}']
                                        }) }
      it "should call default_model_thumbnail" do
        expect(helper).to receive(:default_model_thumbnail).with("TestModel")
        helper.default_thumbnail(document)
      end
    end
  end

end
