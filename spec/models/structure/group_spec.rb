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
end
