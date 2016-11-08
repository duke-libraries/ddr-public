require 'rails_helper'

RSpec.describe EmbedHelper do
  describe "#embeddable?" do
    let(:document) { SolrDocument.new( {'id'=>'changeme:10' } ) }
    params = { controller: 'digital_collections' }
    context "the digital collections item is an image" do
      it "should be embeddable" do      
        document = double("document", :display_format => "image")
        allow(helper).to receive(:params).and_return(params)
        expect(helper.embeddable?(document)).to be true
      end
    end
    context "the digital collections item has no display format" do
      it "should not be embeddable" do      
        document = double("document", :display_format => nil)
        allow(helper).to receive(:params).and_return(params)
        expect(helper.embeddable?(document)).to be false
      end
    end
  end

  describe "purl_or_doclink" do
    let(:document) { SolrDocument.new( {'id'=>'changeme:10' } ) }
    context "item has a permalink" do
      it "should return its permalink" do
        document = double("document", :permanent_url => "http://idn.duke.edu/ark:/99999/fk4yyyyy")
        expect(helper.purl_or_doclink(document)).to eq("http://idn.duke.edu/ark:/99999/fk4yyyyy")
      end
    end
    context "item doesn't have a permalink" do
      it "should return its full path" do
        document = double("document", :permanent_url => nil)
        stub_const('ENV', {'ROOT_URL' => 'https://repository.duke.edu'})
        allow(helper).to receive(:document_or_object_url).and_return('/catalog/changeme:10')
        expect(helper.purl_or_doclink(document)).to include("https://repository.duke.edu/catalog/changeme:10")
      end
    end
  end

  describe "iframe_src_path" do
    let(:document) { SolrDocument.new( {'id'=>'changeme:10' } ) }
    context "item has a permalink with https" do
      it "should return a protocol relative path to embedded view" do
        document = double("document", :permanent_url => "https://idn.duke.edu/ark:/99999/fk4yyyyy")
        expect(helper.iframe_src_path(document)).to eq("//idn.duke.edu/ark:/99999/fk4yyyyy/embed")
      end
    end
    context "item has a permalink with http" do
      it "should return a protocol relative path to embedded view" do
        document = double("document", :permanent_url => "http://idn.duke.edu/ark:/99999/fk4yyyyy")
        expect(helper.iframe_src_path(document)).to eq("//idn.duke.edu/ark:/99999/fk4yyyyy/embed")
      end
    end
  end


end
