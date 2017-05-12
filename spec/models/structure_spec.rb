require 'spec_helper'

RSpec.describe Structure do

  context "Object has default structural metadata" do
    let(:structure) { {"default"=>
      {"type"=>"default", "label"=>"Some Stuff", "contents"=>[
        {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:589"}]},
        {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:590"}]},
        {"order"=>"3", "label"=>"This Thing", "contents"=>[{"repo_id"=>"changeme:591"}]},
        {"order"=>"4", "contents"=>[{"repo_id"=>"changeme:592"}]}]}
      }}

    subject { described_class.new({structure: structure}) }

    it "should return an empty array if the structure is absent" do
      expect(subject.images).to eq([])
    end

    it "should have some default pids" do
      expect(subject.default.pids).to eq(["changeme:589", "changeme:590", "changeme:591", "changeme:592"])
    end

  end

  context "Object has nested structural metadata" do
    let(:structure) {{"default"=>{"type"=>"default", "contents"=>
      [{"id"=>"dukechapel_dcrst003606-images", "type"=>"Images", "label"=>"Multires Images", "contents"=>[
        {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:1030"}]},
        {"order"=>"2", "label"=>"This Image", "contents"=>[{"repo_id"=>"changeme:1031"}]},
        {"order"=>"3", "contents"=>[{"repo_id"=>"changeme:1032"}]}]},
      {"id"=>"dukechapel_dcrst003606-documents", "type"=>"Documents", "contents"=>[
        {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:1029"}]}]}]}}}

    subject { described_class.new({structure: structure}) }

    it "should return an empty array if the structure is absent" do
      expect(subject.default).to eq([])
    end

    it "should have some pids for images" do
      expect(subject.images.pids).to eq(["changeme:1030", "changeme:1031", "changeme:1032"])
    end

    it "should have an id for the images group" do
      expect(subject.images.id).to eq("dukechapel_dcrst003606-images")
    end

    it "should have some pids for files" do
      expect(subject.files.pids).to eq(["changeme:1029"])
    end

    it "should have an id for the files group" do
      expect(subject.files.id).to eq("dukechapel_dcrst003606-documents")
    end

  end

end
