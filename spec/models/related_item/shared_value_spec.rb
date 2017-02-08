require 'spec_helper'

RSpec.describe RelatedItem::SharedValue do

  let(:doc1) { SolrDocument.new('id' => 'changeme:1', 'title' => 'A') }
  let(:doc2) { SolrDocument.new('id' => 'changeme:2', 'title' => 'B') }
  let(:doc3) { SolrDocument.new('id' => 'changeme:3', 'title' => 'C') }
  let(:docs_list) { [doc1, doc2, doc3] }
  let(:config) { {"name"=>"Related Items", "field"=>[:series_facet, :facetable]} }
  let(:facet_vals_counts) { ["West Campus", "10", "SNCC and Civil Rights Movement", "5"] }

  subject { described_class.new({document: doc1, config: config}) }

  before do
    allow(subject).to receive(:facet_values_and_counts) { facet_vals_counts }
    allow(subject).to receive(:relator_field_query) { docs_list }
  end

  its(:name) { is_expected.to eq("Related Items") }
  its(:related_documents) { is_expected.to eq([doc2, doc3]) }
  its(:solr_query) { is_expected.to eq({"f" => {"series_facet_sim" => ["West Campus", "SNCC and Civil Rights Movement"]}, "sort"=>"title_ssi asc"}) }
end
