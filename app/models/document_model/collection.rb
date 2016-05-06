class DocumentModel::Collection

  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include Ddr::Public::Controller::SolrQueryConstructor

  attr_accessor :document

  def initialize(args={})
    @document = args[:document]
  end

  def collection
    document
  end

  def items
    items_search[1]
  end

  def item_count
    items_search[0].total
  end


  private

  def items_search
    response, documents = get_search_results({ q: items_query, rows: 10000 })
  end

  def items_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::IS_MEMBER_OF_COLLECTION, [document.internal_uri])
    construct_query(field_pairs, "OR")
  end

end
