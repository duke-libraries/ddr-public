require "rails_helper"

RSpec.describe CatalogController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

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

  # describe "published / not published" do
  #   let(:obj) { Item.new }
  #   before do
  #     obj.roles.grant type: "Viewer", agent: user
  #     obj.save!
  #     sign_in user
  #   end
  #   describe "when an object is not published" do
  #     it "should not be found" do
  #       get :show, id: obj.pid
  #       expect(response.response_code).to eq(404)
  #     end
  #   end
  #   describe "when an object is published" do
  #     before { obj.publish! }
  #     it "should be found" do
  #       get :show, id: obj.pid
  #       expect(response.response_code).to eq(200)
  #     end
  #   end
  # end

end
