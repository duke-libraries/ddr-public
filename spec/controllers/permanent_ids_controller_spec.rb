require "rails_helper"

RSpec.describe PermanentIdsController do
  describe "#show" do
    describe "when the object does not exist" do
      before { get :show, permanent_id: "ark:/99999/fk4yyyyy" }
      it "should render a 404 not found response" do
        expect(response.response_code).to eq(404)
      end
      it "should render the 404.html template" do
        expect(response).to render_template(file: "#{Rails.root}/public/404.html")
      end
    end
    describe "when the object exists" do
      let(:obj) { Item.new(permanent_id: "ark:/99999/fk4zzzzz") }
      after do
        obj.datastreams['adminMetadata'].delete
        obj.save
      end
      describe "when the object is not published" do
        before do
          obj.save!
          get :show, permanent_id: "ark:/99999/fk4zzzzz"
        end
        it "should be forbidden" do
          expect(response.response_code).to eq(403)
        end
        it "should render the not_published template" do
          expect(response).to render_template(file: "#{Rails.root}/public/not_published.html")
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
