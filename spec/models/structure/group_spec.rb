require 'spec_helper'

RSpec.describe Structure::Group do

  let(:structure) {{"default"=>{"type"=>"default", "contents"=>
    [{"id"=>"dukechapel_dcrst003606-images", "type"=>"Images", "label"=>"Multires Images", "contents"=>[
      {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:1030"}]},
      {"order"=>"2", "label"=> "Special Image", "contents"=>[{"repo_id"=>"changeme:1031"}]},
      {"order"=>"3", "contents"=>[{"repo_id"=>"changeme:1032"}]}]},
    {"id"=>"dukechapel_dcrst003606-documents", "type"=>"Documents", "contents"=>[
      {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:1029"}]}]}]}}}

  subject { described_class.new({structure: structure, type: 'Images'}) }

  its(:pids) { is_expected.to eq(["changeme:1030", "changeme:1031", "changeme:1032"]) }
  its(:label) { is_expected.to eq("Multires Images") }
  its(:labels) { is_expected.to eq([nil, "Special Image", nil]) }
  its(:id) { is_expected.to eq("dukechapel_dcrst003606-images") }

  context "all documents are present" do
    let(:document_pids) {["changeme:1030", "changeme:1031", "changeme:1032"]}
    before {
      ordered_documents = double("ordered_documents")
      allow(subject).to receive(:pids) { document_pids }
      allow(subject).to receive(:ordered_documents).with(document_pids).and_return(document_pids)
    }

    it "should have a list of all the documents" do
      expect(subject.docs).to eq(["changeme:1030", "changeme:1031", "changeme:1032"])
    end

    it "should have a list of all the documents with labels and order values" do
      expect(subject.docs_list).to eq([{:doc=>"changeme:1030", :label=>nil, :order=>"1"},
        {:doc=>"changeme:1031", :label=>"Special Image", :order=>"2"},
        {:doc=>"changeme:1032", :label=>nil, :order=>"3"}])
    end
  end

  context "some of the documents are nil" do
    let(:document_pids) {["changeme:1030", nil, "changeme:1032"]}
    before {
      ordered_documents = double("ordered_documents")
      allow(subject).to receive(:pids) { document_pids }
      allow(subject).to receive(:ordered_documents).with(document_pids).and_return(document_pids)
    }

    it "should have a list of all non-nil documents" do
      expect(subject.docs).to eq(["changeme:1030", "changeme:1032"])
    end

    it "should have a list of all non-nil documents with labels and order values" do
      expect(subject.docs_list).to eq([{:doc=>"changeme:1030", :label=>nil, :order=>"1"},
        {:doc=>"changeme:1032", :label=>nil, :order=>"3"}])
    end
  end

end
