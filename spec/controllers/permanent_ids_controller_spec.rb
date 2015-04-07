require "rails_helper"

RSpec.describe PermanentIdsController do
  describe "#show" do
    describe "when the object does not exist" do
      it "should render a 404 not found response" do
        get :show, permanent_id: "ark:/99999/fkyyyyy"
        expect(response.response_code).to eq(404)
      end
    end
    describe "when the object exists" do
      let(:obj) { Item.new(permanent_id: "ark:/99999/fk4zzzzz") }
      describe "when the object is not published" do
        before { obj.save! }
        it "should render the not_published template" do
          get :show, permanent_id: "ark:/99999/fk4zzzzz"
          expect(response.response_code).to eq(403)
          expect(response).to render_template(:not_published)
        end
      end
      describe "when the object is published" do
        before { obj.publish! }
        it "should redirect to the catalog show view" do
          get :show, permanent_id: "ark:/99999/fk4zzzzz"
          expect(response).to redirect_to(catalog_path(obj))
        end
      end
    end
  end
end
