require "rails_helper"

RSpec.describe PermanentIdsController do
  describe "#show" do
    let!(:obj) { Item.create(permanent_id: "ark:/99999/fk4zzzzz") }
    it "should redirect to the catalog show view" do
      get :show, permanent_id: "ark:/99999/fk4zzzzz"
      expect(response).to redirect_to(catalog_path(obj))
    end
  end
end
