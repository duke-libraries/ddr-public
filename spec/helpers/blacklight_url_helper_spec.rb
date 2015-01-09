require 'rails_helper'

RSpec.describe BlacklightUrlHelper do

  describe "#url_for_document" do
    let(:document) { SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Component',
            'workflow_state_ssi'=>'published',
            'object_profile_ssm'=>['{"datastreams":{"content":{"dsLabel":"image10.tif","dsVersionID":"content.0","dsCreateDate":"2014-10-22T17:30:02Z","dsState":"A","dsMIME":"image/tiff","dsFormatURI":null,"dsControlGroup":"M","dsSize":69742260,"dsVersionable":true,"dsInfoType":null,"dsLocation":"changeme:10+content+content.0","dsLocationType":"INTERNAL_ID","dsChecksumType":"SHA-256","dsChecksum":"b9eb20b6fb4a27d6bf478bdefb25538bea95740bdf48471ec360d25af622a911"}}}']
            ) }
    context "object has permanent URL" do
      let(:permanent_url) { "http://id.library.duke.edu/ark:/99999/fk4zzz" }
      before { document.merge!(Ddr::IndexFields::PERMANENT_URL => permanent_url) }
      it "should return the permanent URL" do
        expect(helper.url_for_document(document)).to eq(permanent_url)
      end
    end
    context "object does not have permanent URL" do
      it "should return the default Blacklight URL for the object" do
        expect(helper.url_for_document(document)).to eq(document)
      end
    end
  end

end