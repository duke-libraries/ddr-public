require 'rails_helper'

RSpec.describe StreamController, type: :controller do

  describe "#show" do
    let(:document) { double(SolrDocument.new(id: 'changeme:123')) }
    before { allow(SolrDocument).to receive(:find).with('changeme:123') { document } }

    context "user has read permissions" do
      before { controller.current_ability.can(:read, 'changeme:123') }

      context "asset doesn't have streamable media" do
        it "should raise a 404 error" do
          allow(document).to receive(:streamable?).and_return(false)
          get :show, { controller: 'stream', id: 'changeme:123'}
          expect(response.response_code).to eq(404)
        end
      end
    end

    context "user doesn't have read permissions" do
      before { controller.current_ability.cannot(:read, 'changeme:123') }

      it "should raise an access denied error" do
        allow(document).to receive(:streamable?).and_return(true)
        expect{ get :show, { controller: 'stream', id: 'changeme:123'} }.to raise_error(CanCan::AccessDenied)
      end

    end

  end

end
