require "rails_helper"

RSpec.describe CatalogController, type: :controller do
  describe "authorization failure" do
    before { allow(controller).to receive(:index).and_raise(CanCan::AccessDenied) }
    describe "when user is signed in" do
      before { allow(controller).to receive(:user_signed_in?) { true } }
      it "should return an unauthorized response" do
        get :index
        expect(response.response_code).to eq(403)
        expect(response).to render_template(file: "#{Rails.root}/public/403.html")
      end
    end
    describe "when user is not signed in" do
      before { allow(controller).to receive(:user_signed_in?) { false } }
      it "should force the user to authenticate" do
        expect(controller).to receive(:authenticate_user!)
        get :index
      end
    end
  end
end
