require 'rails_helper'

RSpec.describe BlacklightHelper do

  describe "#document_or_object_url" do
    let(:doc_or_obj) { SolrDocument.new(SolrDocument.new(
      'id' => 'changeme:2',
      ) ) }
    before { allow(doc_or_obj).to receive(:public_action).and_return('show') }
    context "document has a public_collection defined" do
      it "should return a collection scoped url to a document" do
        allow(doc_or_obj).to receive(:public_controller).and_return('digital_collections')
        allow(doc_or_obj).to receive(:public_collection).and_return('wdukesons')
        allow(doc_or_obj).to receive(:public_id).and_return('dcci0101')
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'digital_collections', collection: 'wdukesons', action: 'show', id: 'dcci0101')
      end
    end
    context "document does not have a public_collection defined" do
      it "should return a url for an show view without a collection path" do
        allow(doc_or_obj).to receive(:public_controller).and_return('catalog')
        allow(doc_or_obj).to receive(:public_collection).and_return(nil)
        allow(doc_or_obj).to receive(:public_id).and_return('changeme:2')
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'catalog', action: 'show', id: 'changeme:2')
      end
    end
  end

end
