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

end
