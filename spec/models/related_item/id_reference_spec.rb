require 'spec_helper'

RSpec.describe RelatedItem::IdReference do

  let(:doc1) { SolrDocument.new('id' => 'changeme:1', 'title' => 'A') }
  let(:doc2) { SolrDocument.new('id' => 'changeme:2', 'title' => 'B') }
  let(:doc3) { SolrDocument.new('id' => 'changeme:3', 'title' => 'C') }
  let(:docs_list) { [doc1, doc2, doc3] }
  let(:docs_count) { 3 }
  let(:config) { {"name"=>"Related Items", "field"=>[:series_facet, :facetable], "id_field"=>[:permanent_id, :stored_sortable]} }
  let(:values) { ["ark:/99999/1111", "ark:/99999/2222"] }

  subject { described_class.new({document: doc1, config: config}) }

  before do
    allow(subject).to receive(:document_field_values) { values }
    allow(subject).to receive(:title_sorted_documents) { docs_list }
    allow(subject).to receive(:document_count) { docs_count }
  end

  its(:name) { is_expected.to eq("Related Items") }
  its(:related_documents) { is_expected.to eq([doc1, doc2, doc3]) }
  its(:related_documents_count) { is_expected.to eq(3) }
  its(:solr_query) { is_expected.to eq({"id_related_items"=>"changeme:1|series_facet_sim|permanent_id_ssi", "sort"=>"title_ssi asc", "q"=>"", "search_field"=>"all_fields"}) }
end
