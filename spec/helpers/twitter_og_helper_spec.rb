require 'rails_helper'

RSpec.describe TwitterOgHelper do

  describe "#og_absolute_url" do
    before do
      allow(helper).to receive(:root_url).and_return("https://repository.duke.edu")
    end
    context "a path is already absolute" do
      let(:path) { "https://repository.duke.edu/iipsrv/iipsrv.fcgi?IIIF=/srv/perkins/repo_deriv/multires_image/1/2/34/1234/abcd010230010.ptif/pct:5,5,90,90/600,/0/default.jpg" }
      it "should return the path as is" do
        expect(helper.og_absolute_url(path)).to eq("https://repository.duke.edu/iipsrv/iipsrv.fcgi?IIIF=/srv/perkins/repo_deriv/multires_image/1/2/34/1234/abcd010230010.ptif/pct:5,5,90,90/600,/0/default.jpg")
      end
    end
    context "a path is protocol-relative" do
      let(:path) { "//idn.duke.edu/ark:/99999/fk43x8jr66?embed=true" }
      it "should return an absolute path with https" do
        expect(helper.og_absolute_url(path)).to eq("https://idn.duke.edu/ark:/99999/fk43x8jr66?embed=true")
      end
    end
    context "a path is root-relative" do
      let(:path) { "/assets/ddr-portals/dukechapel/dukechapel-causeway.jpg" }
      it "should return an absolute path with the root url" do
        expect(helper.og_absolute_url(path)).to eq("https://repository.duke.edu/assets/ddr-portals/dukechapel/dukechapel-causeway.jpg")
      end
    end
  end
end
