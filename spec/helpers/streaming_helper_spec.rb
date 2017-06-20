require 'rails_helper'

RSpec.describe StreamingHelper do

  describe "#stream_urls" do
    let(:document) { SolrDocument.new('id'=>'changeme:10') }

    before do
      allow(document).to receive(:media_paths).and_return(['/stream/changeme:11', '/stream/changeme:12'])
    end

    context "has older deprecated derivative paths" do
      it "should use the deprecated derivatives" do
        allow(helper).to receive(:derivative_urls).with(document) { ['http://library.duke.edu/dc/media-1.mp3','http://library.duke.edu/dc/media-2.mp3'] }
        expect(helper.stream_urls(document)).to eq(['http://library.duke.edu/dc/media-1.mp3','http://library.duke.edu/dc/media-2.mp3'])
      end
    end

    context "has derivatives stored as streamable media in DDR" do
      it "should use the DDR stream paths" do
        allow(helper).to receive(:derivative_urls).with(document) { nil }
        expect(helper.stream_urls(document)).to eq(['/stream/changeme:11', '/stream/changeme:12'])
      end
    end


  end

end
