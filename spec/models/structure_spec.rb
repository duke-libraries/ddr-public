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

    it "has some default pids" do
      expect(subject.default.pids).to eq(["changeme:589", "changeme:590", "changeme:591", "changeme:592"])
    end
  end

  context "Object has nested structural metadata with images" do
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

    it "has some pids for images" do
      expect(subject.images.pids).to eq(["changeme:1030", "changeme:1031", "changeme:1032"])
    end

    it "has an id for the images group" do
      expect(subject.images.id).to eq("dukechapel_dcrst003606-images")
    end

    it "has some pids for files" do
      expect(subject.files.pids).to eq(["changeme:1029"])
    end

    it "has an id for the files group" do
      expect(subject.files.id).to eq("dukechapel_dcrst003606-documents")
    end
  end

  context "Object has nested structural metadata with AV and documents" do
    let(:structure) {{"default"=>{"type"=>"default", "contents"=>
      [{"id"=>"dukechapel_dcrau001201-media", "type"=>"Media", "contents"=>[
        {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:1900"}]},
        {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:1901"}]},
        {"order"=>"3", "contents"=>[{"repo_id"=>"changeme:1902"}]}]},
      {"id"=>"dukechapel_dcrau001201-documents", "type"=>"Documents", "contents"=>[
        {"order"=>"1", "label"=>"Transcript", "contents"=>[{"repo_id"=>"changeme:1905"}]}]}]}}}

    subject { described_class.new({structure: structure}) }

    it "has some pids for media objects" do
      expect(subject.media.pids).to eq(["changeme:1900", "changeme:1901", "changeme:1902"])
    end

    it "has an id for the media group" do
      expect(subject.media.id).to eq("dukechapel_dcrau001201-media")
    end
  end

  context "Object has directory structural metadata" do
    let(:structure) do
      {"default"=>
        {"type"=>"default",
         "contents"=>
          [{"label"=>"test-nested",
            "order"=>"1",
            "type"=>"Directory",
            "contents"=>
             [{"label"=>"Youth",
               "order"=>"1",
               "type"=>"Directory",
               "contents"=>
                [{"label"=>"Americorps",
                  "order"=>"1",
                  "type"=>"Directory",
                  "contents"=>
                   [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2080"}]},
                    {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2081"}]},
                    {"order"=>"3", "contents"=>[{"repo_id"=>"changeme:2082"}]},
                    {"order"=>"4", "contents"=>[{"repo_id"=>"changeme:2083"}]},
                    {"label"=>"Kathryn AmeriCorps",
                     "order"=>"5",
                     "type"=>"Directory",
                     "contents"=>
                      [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2084"}]},
                       {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2085"}]}]},
                    {"order"=>"6", "contents"=>[{"repo_id"=>"changeme:2086"}]},
                    {"order"=>"7", "contents"=>[{"repo_id"=>"changeme:2087"}]},
                    {"order"=>"8", "contents"=>[{"repo_id"=>"changeme:2088"}]}]},
                 {"label"=>"Archivos temporales",
                  "order"=>"2",
                  "type"=>"Directory",
                  "contents"=>
                   [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2089"}]},
                    {"order"=>"2",
                     "contents"=>[{"repo_id"=>"changeme:2090"}]}]}]}]}]}}
    end

    subject { described_class.new({structure: structure}) }

    it "has directory structural metadata" do
      expect(subject.directories).to eq(
        [{"label"=>"test-nested",
          "order"=>"1",
          "type"=>"Directory",
          "contents"=>
           [{"label"=>"Youth",
             "order"=>"1",
             "type"=>"Directory",
             "contents"=>
              [{"label"=>"Americorps",
                "order"=>"1",
                "type"=>"Directory",
                "contents"=>
                 [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2080"}]},
                  {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2081"}]},
                  {"order"=>"3", "contents"=>[{"repo_id"=>"changeme:2082"}]},
                  {"order"=>"4", "contents"=>[{"repo_id"=>"changeme:2083"}]},
                  {"label"=>"Kathryn AmeriCorps",
                   "order"=>"5",
                   "type"=>"Directory",
                   "contents"=>
                    [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2084"}]},
                     {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2085"}]}]},
                  {"order"=>"6", "contents"=>[{"repo_id"=>"changeme:2086"}]},
                  {"order"=>"7", "contents"=>[{"repo_id"=>"changeme:2087"}]},
                  {"order"=>"8", "contents"=>[{"repo_id"=>"changeme:2088"}]}]},
               {"label"=>"Archivos temporales",
                "order"=>"2",
                "type"=>"Directory",
                "contents"=>
                 [{"order"=>"1", "contents"=>[{"repo_id"=>"changeme:2089"}]},
                  {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:2090"}]}]}]}]}]
      )
    end
  end

  context "Object does not have directory structural metadata" do
    let(:structure) { {"default"=>
      {"type"=>"default", "label"=>"Some Stuff", "contents"=>[
        {"order"=>"1", "contents"=>[{"repo_id"=>"changeme:589"}]},
        {"order"=>"2", "contents"=>[{"repo_id"=>"changeme:590"}]},
        {"order"=>"3", "label"=>"This Thing", "contents"=>[{"repo_id"=>"changeme:591"}]},
        {"order"=>"4", "contents"=>[{"repo_id"=>"changeme:592"}]}]}
      }}
    subject { described_class.new({structure: structure}) }

    it "returns an empty array" do
      expect(subject.directories).to eq([])
    end
  end

end
