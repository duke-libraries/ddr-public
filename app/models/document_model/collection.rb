class DocumentModel::Collection

  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Ddr::Public::Controller::SolrQueryConstructor
  include DocumentModel::Searcher

  attr_accessor :document

  def initialize(args={})
    @document = args[:document]
  end

  def collection
    document
  end

  def items
    items_search.documents
  end

  def item_count
    items_search.total
  end

  def metadata_header
    "Collection Info"
  end

  private

  def items_search
    query = searcher.where(items_query).merge({rows: 10000})
    repository.search(query)
  end

  def items_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::IS_MEMBER_OF_COLLECTION, [document.internal_uri])
    construct_query(field_pairs, "OR")
  end

end
