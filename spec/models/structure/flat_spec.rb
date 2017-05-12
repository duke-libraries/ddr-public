require 'spec_helper'

RSpec.describe Structure::Flat do

  let(:structure) { {"default"=>
    {"type"=>"default", "contents"=>[
      {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:589"}]},
      {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:590"}]},
      {"order"=>"3", "label"=> "Special Thing", "contents"=>[{"repo_id"=>"changeme:591"}]},
      {"order"=>"4", "contents"=>[{"repo_id"=>"changeme:592"}]}]}
    }}

  subject { described_class.new({structure: structure, type: 'default'}) }

  its(:pids) { is_expected.to eq(["changeme:589", "changeme:590", "changeme:591", "changeme:592"]) }
  its(:label) { is_expected.to be_nil }
  its(:labels) { is_expected.to eq([nil, nil, "Special Thing", nil]) }
  its(:order) { is_expected.to eq(["1", "2", "3", "4"]) }

  context "all documents are present" do
    let(:document_pids) {["changeme:589", "changeme:590", "changeme:591", "changeme:592"]}
    before {
      ordered_documents = double("ordered_documents")
      allow(subject).to receive(:pids) { document_pids }
      allow(subject).to receive(:ordered_documents).with(document_pids).and_return(document_pids)
    }

    it "should have a list of all the documents" do
      expect(subject.docs).to eq(["changeme:589", "changeme:590", "changeme:591", "changeme:592"])
    end

    it "should have a list of all the documents with labels and order values" do
      expect(subject.docs_list).to eq([{:doc=>"changeme:589", :label=>nil, :order=>"1"},
        {:doc=>"changeme:590", :label=>nil, :order=>"2"},
        {:doc=>"changeme:591", :label=>"Special Thing", :order=>"3"},
        {:doc=>"changeme:592", :label=>nil, :order=>"4"}])
    end
  end

  context "some of the documents are nil" do
    let(:document_pids) {["changeme:589", nil, "changeme:591", nil]}
    before {
      ordered_documents = double("ordered_documents")
      allow(subject).to receive(:pids) { document_pids }
      allow(subject).to receive(:ordered_documents).with(document_pids).and_return(document_pids)
    }

    it "should have a list of all non-nil documents" do
      expect(subject.docs).to eq(["changeme:589", "changeme:591"])
    end

    it "should have a list of all non-nil documents with labels and order values" do
      expect(subject.docs_list).to eq([{:doc=>"changeme:589", :label=>nil, :order=>"1"},
        {:doc=>"changeme:591", :label=>"Special Thing", :order=>"3"}])
    end
  end

end
