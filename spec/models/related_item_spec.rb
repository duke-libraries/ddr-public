require 'spec_helper'

RSpec.describe RelatedItem do

  let(:doc1) { SolrDocument.new('id' => 'changeme:2') }
  let(:doc2) { SolrDocument.new('id' => 'changeme:3') }
  let(:docs_list) { [doc1, doc2] }
  let(:config) { {"name"=>"Related Items", "field"=>[:series_facet, :facetable]} }
  let(:facet_vals_counts) { ["West Campus", "10", "SNCC and Civil Rights Movement", "5"] }

  subject { described_class.new({document: doc1, config: config}) }

    before do
      allow(subject).to receive(:facet_values_and_counts) { facet_vals_counts }
      allow(subject).to receive(:relator_field_query) { docs_list }
    end

  its(:name) { is_expected.to eq("Related Items") }
  its(:solr_field) { is_expected.to eq("series_facet_sim")}
  its(:solr_values) { is_expected.to eq(["West Campus", "SNCC and Civil Rights Movement"])}
  its(:solr_params) { is_expected.to eq({"f" => {"series_facet_sim" => ["West Campus", "SNCC and Civil Rights Movement"]}}) }
  its(:related_documents) { is_expected.to eq([doc2]) }
end
