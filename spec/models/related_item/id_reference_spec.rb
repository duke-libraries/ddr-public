require 'spec_helper'

RSpec.describe RelatedItem::IdReference do

  let(:doc1) { SolrDocument.new('id' => 'changeme:1', 'title' => 'A') }
  let(:doc2) { SolrDocument.new('id' => 'changeme:2', 'title' => 'B') }
  let(:doc3) { SolrDocument.new('id' => 'changeme:3', 'title' => 'C') }
  let(:docs_list) { [doc1, doc2, doc3] }
  let(:config) { {"name"=>"Related Items", "field"=>[:series_facet, :facetable], "id_field"=>[:permanent_id, :stored_sortable]} }
  let(:values) { ["ark:/99999/1111", "ark:/99999/2222"] }

  subject { described_class.new({document: doc1, config: config}) }

  before do
    allow(subject).to receive(:document_field_values) { values }
    allow(subject).to receive(:title_sorted_documents) { docs_list }
  end

  its(:name) { is_expected.to eq("Related Items") }
  its(:related_documents) { is_expected.to eq([doc1, doc2, doc3]) }
  its(:solr_query) { is_expected.to eq({"f"=>{"permanent_id_ssi"=>"\"ark:/99999/1111 OR ark:/99999/2222\""}, "sort"=>"title_ssi asc"}) }
end
