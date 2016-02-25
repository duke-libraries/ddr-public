require "rails_helper"

RSpec.describe CatalogController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

  describe "authorization failure" do
    before { allow(controller).to receive(:index).and_raise(CanCan::AccessDenied) }

    describe "when user is signed in" do
      before { allow(controller).to receive(:user_signed_in?) { true } }
      xit "should return an unauthorized response" do
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

  describe "published / not published" do
    let(:viewer_role) { Ddr::Auth::Roles::Role.new(role_type: "Viewer", agent: user) }
    let(:obj) { Item.new }
    before do
      obj.roles.roles= viewer_role
      obj.save!
      sign_in user
    end
    describe "when an object is not published" do
      xit "should not be found" do
        get :show, id: obj.id
        expect(response.response_code).to eq(404)
      end
    end
    describe "when an object is published" do
      before { obj.publish! }
      xit "should be found" do
        get :show, id: obj.id
        expect(response.response_code).to eq(200)
      end
    end
  end

end
