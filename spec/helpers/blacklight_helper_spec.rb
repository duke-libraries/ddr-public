require 'rails_helper'

RSpec.describe BlacklightHelper do

  describe "#document_or_object_url" do
    let (:configs) { {"blake"=>{:collection=>[{:controller=>"blake", :action=>:index}], :item=>[{:controller=>"blake", :action=>:show}], :component=>[{:controller=>"blake", :action=>:show}]}, "wdukesons"=>{:collection=>[{:controller=>"wdukesons", :action=>:index}], :item=>[{:controller=>"wdukesons", :action=>:show}], :component=>[{:controller=>"wdukesons", :action=>:show}]}, "vica"=>{:collection=>[{:controller=>"digital_collections", :action=>:show}], :item=>[{:controller=>"digital_collections", :action=>:show}], :component=>[{:controller=>"digital_collections", :action=>:show}]}, "nescent"=>{:collection=>[{:controller=>"nescent", :action=>:show}], :item=>[{:controller=>"nescent", :action=>:show}], :component=>[{:controller=>"nescent", :action=>:show}]}} }
    before { allow(helper).to receive(:portal_controllers_and_actions).and_return(configs) }
    before { allow(helper).to receive(:select_document_id).and_return(document_id) }
    before { allow(helper).to receive(:filter_values_for_document).and_return(filter_values) }
    context "document is a collection that has a portal" do
      let(:doc_or_obj) { SolrDocument.new(SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Collection',
            ) ) }
      let(:document_id) { nil }
      let(:filter_values) { ["blake", nil] }
      it "should return a url for an index view" do
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'blake', action: :index, id: nil)
      end
    end

    context "document is a collection that does not have a portal" do
      let(:doc_or_obj) { SolrDocument.new(SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Collection',
            ) ) }
      let(:document_id) { doc_or_obj }
      let(:filter_values) { ["chuck", nil] }
      it "should return a url for the show view for the collection" do
        allow(helper).to receive(:controller_name).and_return ("catalog")
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'catalog', action: :show, id: doc_or_obj)
      end
    end

    context "document is an item that has a portal" do
      let(:doc_or_obj) { SolrDocument.new(SolrDocument.new(
            'id'=>'changeme:10',
            'active_fedora_model_ssi'=>'Item',
            ) ) }
      let(:document_id) { doc_or_obj }
      let(:filter_values) { ["blake", nil] }
      it "should return a url for the item show page scoped to the portal" do
        expect(helper.document_or_object_url(doc_or_obj)).to include(url_for controller: 'blake', action: :show, id: doc_or_obj)
      end
    end
  end

  describe "#select_action_for_collection" do
    context "controller_type_name is 'collections'" do
      let(:controller_type_name) { "collections" }
      it "should return :index" do
        expect(helper.select_action_for_collection(controller_type_name)).to eq(:index)
      end
    end
    context "controller_type_name is 'portals'" do
      let(:controller_type_name) { "portals" }
      it "should return doc_or_obj" do
        expect(helper.select_action_for_collection(controller_type_name)).to eq(:show)
      end
    end
  end

  describe "#select_document_id" do
    let(:action) { :show }
    context "document is an item without a local_id" do
      let(:doc_or_obj) { SolrDocument.new(SolrDocument.new(
          'id'=>'changeme:10',
          'active_fedora_model_ssi'=>'Item',
          ) ) }
      it "should return the pid as the document id" do
        expect(helper.select_document_id(action, doc_or_obj)).to eq(doc_or_obj)
      end
    end
    context "document is an item with a local_id and part of dc admin_set" do
      let(:local_id) { 'dscsi04067' }
      let(:doc_or_obj) { SolrDocument.new(SolrDocument.new(
          'id'=>'changeme:10',
          'active_fedora_model_ssi'=>'Item',
          'local_id_ssi'=> local_id,
          'admin_set_ssi'=>'dc'
          ) ) }
      it "should return the local_id as the document id" do
        expect(helper.select_document_id(action, doc_or_obj)).to eq(local_id)
      end
    end
  end

end
