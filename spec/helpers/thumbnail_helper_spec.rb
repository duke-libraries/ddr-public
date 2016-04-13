require 'rails_helper'

RSpec.describe ThumbnailHelper do

  describe "#thumbnail_image_tag" do
    context "the object has a thumbnail" do
      let(:document) { SolrDocument.new({
              'id'=>'changeme:10',
              'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"},"thumbnail":{"dsLabel":"Thumbnail for this object","dsVersionID":"thumbnail.0","dsCreateDate":"2014-10-22T17:30:13Z","dsState":"A","dsMIME":"image/png","dsFormatURI":null,"dsControlGroup":"M","dsSize":59185,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+thumbnail+thumbnail.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"bc7e49e9864267860b66b5dd936332016d157e43b6d6b0a547d59c4699b9191c"}}}']
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
              'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}']
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
              'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}']
              }) }
      it "should call default_mime_type_thumbnail" do
        expect(helper).to receive(:default_mime_type_thumbnail).with("image/tiff")
        helper.default_thumbnail(document)
      end
    end
    context "object does not have content but does have a display format" do
      let(:document) { SolrDocument.new({
              'id'=>'changeme:10',
              'display_format_ssi' => 'audio',
              'object_profile_ssm'=>['{"datastreams":{}}']
              }) }
      it "should call default_display_format_thumbnail" do
        expect(helper).to receive(:default_display_format_thumbnail).with("audio")
        helper.default_thumbnail(document)
      end
    end
    context "object does not have content" do
      let(:document) { SolrDocument.new({
              'active_fedora_model_ssi'=>'TestModel',
              'id'=>'changeme:10',
              'object_profile_ssm'=>['{"datastreams":{}}']
              }) }
      it "should call default_model_thumbnail" do
        expect(helper).to receive(:default_model_thumbnail).with("TestModel")
        helper.default_thumbnail(document)
      end      
    end
  end

end