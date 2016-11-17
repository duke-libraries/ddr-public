require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do

  let(:user) { FactoryGirl.create(:user) }

  controller do
    def index
      render nothing: true
    end
  end

  describe "when the user is signed in" do
    before { sign_in user }
    describe "and Shib authn is required" do
      before {
        allow(Ddr::Auth).to receive(:require_shib_user_authn) { true }
      }
      describe "and there is no Shib session" do
        before {
          allow(controller).to receive(:shib_session?) { false }
        }
        it "signs the user out" do
          expect(controller).to receive(:sign_out)
          get :index
        end
      end
      describe "and there is a Shib session" do
        before {
          allow(controller).to receive(:shib_session?) { true }
        }
        it "does not sign the user out" do
          expect(controller).not_to receive(:sign_out)
          get :index
        end
      end
    end
    describe "and Shib authn is not required" do
      before {
        allow(Ddr::Auth).to receive(:require_shib_user_authn) { false }
      }
      describe "and there is no Shib session" do
        before {
          allow(controller).to receive(:shib_session?) { false }
        }
        it "does not sign the user out" do
          expect(controller).not_to receive(:sign_out)
          get :index
        end
      end
      describe "and there is a Shib session" do
        before {
          allow(controller).to receive(:shib_session?) { true }
        }
        it "does not sign the user out" do
          expect(controller).not_to receive(:sign_out)
          get :index
        end
      end
    end
  end

end
