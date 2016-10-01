class DocumentModel::Component

  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Ddr::Public::Controller::SolrQueryConstructor
  include DocumentModel::Searcher

  attr_accessor :document

  def initialize(args={})
    @document = args[:document]
  end

  def collection
    collection_search.documents.first
  end

  def item
    item_search.documents.first
  end

  def metadata_header
    "File Info"
  end

  private

  def collection_search
    query = searcher.query({ q: collection_query, rows: '10' })
    repository.search(query)
  end

  def collection_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::INTERNAL_URI, [document.collection_uri])
    construct_query(field_pairs, "OR")
  end

  def item_search
    query = searcher.query({ q: item_query, rows: '10' })
    repository.search(query)
  end

  def item_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::INTERNAL_URI, [document.is_part_of])
    construct_query(field_pairs, "OR")
  end

end
