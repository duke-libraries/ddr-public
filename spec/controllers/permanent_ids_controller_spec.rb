require "rails_helper"

RSpec.describe PermanentIdsController do

  describe "#show" do
    let!(:permanent_id) { "ark:/99999/fk4yyyyy" }
    let!(:query_params) { {q: "#{Ddr::Index::Fields::PERMANENT_ID}:\"#{permanent_id}\"", rows: 1} }

    describe "when the object does not exist" do
      before do
        allow(controller).to receive(:query_solr).with(query_params) do
          double(total: 0)
        end
      end
      it "should render a 404 not found response" do
        get :show, permanent_id: permanent_id
        expect(response.response_code).to eq(404)
        expect(response).to render_template(file: "#{Rails.root}/public/404.html")
      end
    end

    describe "when the object exists" do
      before do
        allow(controller).to receive(:query_solr).with(query_params) do
          double(total: 1, documents: [{"id"=>"test:1"}])
        end
      end
      it "should redirect to the catalog show view" do
        get :show, permanent_id: permanent_id
        expect(response).to redirect_to(catalog_path({"id"=>"test:1"}))
      end
    end
  end

end
