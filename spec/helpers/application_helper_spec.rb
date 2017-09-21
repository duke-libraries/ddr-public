require 'rails_helper'

RSpec.describe ApplicationHelper do

  describe "#has_search_parameters?" do

    context "params contains a search parameter" do
      params = { q: 'foo' }
      it "is true" do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.has_search_parameters?).to be_truthy
      end
    end

    context "params does not contain a search parameter" do
      params = {}
      it "is false" do
        allow(helper).to receive(:params).and_return(params)
        expect(helper.has_search_parameters?).to be_falsey
      end
    end

  end

end
