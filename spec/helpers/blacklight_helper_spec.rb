require 'rails_helper'

RSpec.describe BlacklightHelper do

  describe "#document_or_object_url" do
    let(:doc_or_obj) { SolrDocument.new(
      'id' => 'changeme:2',
      ) }
    before { allow(doc_or_obj).to receive(:public_action).and_return('show') }
    context "document has a public_collection defined" do
      it "should return a collection scoped url to a document" do
        allow(doc_or_obj).to receive(:public_controller).and_return('digital_collections')
        allow(doc_or_obj).to receive(:public_collection).and_return('wdukesons')
        allow(doc_or_obj).to receive(:public_id).and_return('dcci0101')
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'digital_collections', collection: 'wdukesons', action: 'show', id: 'dcci0101')
      end
    end
    context "document does not have a public_collection defined" do
      it "should return a url for an show view without a collection path" do
        allow(doc_or_obj).to receive(:public_controller).and_return('catalog')
        allow(doc_or_obj).to receive(:public_collection).and_return(nil)
        allow(doc_or_obj).to receive(:public_id).and_return('changeme:2')
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'catalog', action: 'show', id: 'changeme:2')
      end
    end
  end

  describe BlacklightHelper::DdrPublicDocumentPresenter do

    let(:request_context) { double(:add_facet_params => '') }
    let(:config) { Blacklight::Configuration.new }

    subject { presenter }
    let(:presenter) { BlacklightHelper::DdrPublicDocumentPresenter.new(document, request_context, config) }

    let(:document) do
      SolrDocument.new(id: 1, 
                       'link_to_search_true' => 'x', 
                       'link_to_search_named' => 'x',
                       'qwer' => 'document qwer value',
                       'mnbv' => 'document mnbv value',
                       'wall_of_text' => 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                       'so_many_subjects' => ["one", "two", "three", "four", "five", "six", "seven"])
    end

    describe "render_document_show_field_value" do
      let(:config) do
        Blacklight::Configuration.new.configure do |config|
          config.add_show_field 'wall_of_text'
          config.add_show_field 'so_many_subjects'
          config.add_show_field 'qwer'
          config.add_show_field 'asdf', :helper_method => :render_asdf_document_show_field
          config.add_show_field 'link_to_search_true', :link_to_search => true
          config.add_show_field 'link_to_search_named', :link_to_search => :some_field
          config.add_show_field 'highlight', :highlight => true
        end
      end

      it "should check for an explicit value" do
        expect(request_context).to_not receive(:render_asdf_document_show_field)
        value = subject.render_document_show_field_value 'asdf', :value => 'val1'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li>val1</li></ul>"
      end

      it "should check for a helper method to call" do
        allow(request_context).to receive(:render_asdf_document_show_field).and_return('custom asdf value')
        value = subject.render_document_show_field_value 'asdf'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li>custom asdf value</li></ul>"
      end

      it "should check for a link_to_search" do
        allow(request_context).to receive(:search_action_path).with('').and_return('/foo')
        allow(request_context).to receive(:link_to).with("x", '/foo').and_return('bar')
        value = subject.render_document_show_field_value 'link_to_search_true'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li>bar</li></ul>"
      end

      it "should check for a link_to_search with a field name" do
        allow(request_context).to receive(:search_action_path).with('').and_return('/foo')
        allow(request_context).to receive(:link_to).with("x", '/foo').and_return('bar')
        value = subject.render_document_show_field_value 'link_to_search_named'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li>bar</li></ul>"
      end

      it "should gracefully handle when no highlight field is available" do
        allow(document).to receive(:has_highlight_field?).and_return(false)
        value = subject.render_document_show_field_value 'highlight'
        expect(value).to be_blank
      end

      it "should check for a highlighted field" do
        allow(document).to receive(:has_highlight_field?).and_return(true)
        allow(document).to receive(:highlight_field).with('highlight').and_return(['<em>highlight</em>'.html_safe])
        value = subject.render_document_show_field_value 'highlight'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li><em>highlight</em></li></ul>"
      end

      it "should add the correct class to a field with few values" do
        value = subject.render_document_show_field_value 'qwer'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li>document qwer value</li></ul>"
      end

      it "should add the correct class to a field with long values" do
        value = subject.render_document_show_field_value 'wall_of_text'
        expect(value).to eq "<ul class=\"long-metadata-values\"><li>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.</li></ul>"
      end

      it "should add the correct class to a field with many values" do
        value = subject.render_document_show_field_value 'so_many_subjects'
        expect(value).to eq "<ul class=\"many-metadata-values\"><li>one</li><li>two</li><li>three</li><li>four</li><li>five</li><li>six</li><li>seven</li></ul>"
      end

      it "should work with show fields that aren't explicitly defined" do
        value = subject.render_document_show_field_value 'mnbv'
        expect(value).to eq "<ul class=\"few-metadata-values\"><li>document mnbv value</li></ul>"
      end

    end

  end

end
