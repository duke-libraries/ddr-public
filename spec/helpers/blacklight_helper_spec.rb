require 'rails_helper'

RSpec.describe BlacklightHelper do

  describe "#render_document_partials" do
    let(:doc) { double }
    let(:blacklight_config) { double }

    before :each do
      allow(helper).to receive_messages(document_partial_path_templates: [])
      allow(helper).to receive_messages(document_index_view_type: 'index_header')
    end
    
    it "should get the document format from document_partial_name" do
      allow(helper).to receive(:document_partial_name).with(doc, 'display_type_field', :xyz, true)
      allow(helper).to receive(:document_partial_name).with(doc, 'collection_name_field', :xyz)
      allow(helper).to receive(:document_partial_name).with(doc, 'active_fedora_model_field', :xyz)
      helper.render_document_partial(doc, :xyz)    
    end

  end

end