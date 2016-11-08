require 'rails_helper'

RSpec.describe DigitalCollectionsController, type: :controller do
  describe "#embed" do
    xit "should not have X-Frame-Options in the headers (else iframe embed is prevented)" do
      get :embed, id: "dscsi03002", collection: "wdukesons"
      expect(response.headers['X-Frame-Options']).to be_nil
    end
  end

end
