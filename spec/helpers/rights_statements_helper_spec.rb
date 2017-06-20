require 'rails_helper'

RSpec.describe RightsStatementsHelper do

  describe "#rights_display" do
    let(:document) { SolrDocument.new('id'=>'changeme:10') }
    let(:rights_statement) { double("rights_statement", {
      id: 1,
      url: "http://example.org/licenses/foo",
      title: "Creative Commons Attribution 4.0 International",
      short_title: "CC BY 4.0",
      reuse_text: "Free Re-Use",
      feature: ['cc-cc','cc-by']
     }) }

    before do
      allow(document).to receive(:rights_statement).and_return(rights_statement)
      allow(document).to receive(:rights).and_return(["https://creativecommons.org/licenses/by/4.0/"])
    end

    context "reuse text is present" do

      it "should display the reuse text" do
        expect(helper.rights_display(:document => document)).to include('Free Re-Use')
      end
    end

    context "has two feature icon classes" do

      it "should render icon spans" do
        expect(helper.rights_display(:document => document)).to include('<span class="icon-rights icon-rights-cc-cc">','<span class="icon-rights icon-rights-cc-by">')
      end
    end

    context "rights statement URI is not found" do
      it "should display a link to the URI" do
        allow(document).to receive(:rights_statement).and_raise(Ddr::Models::NotFoundError, "404")
        expect(helper.rights_display(:document => document)).to eq('<a href="https://creativecommons.org/licenses/by/4.0/">https://creativecommons.org/licenses/by/4.0/</a>')
      end
    end

  end

end
