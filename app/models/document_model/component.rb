class DocumentModel::Component

  include Blacklight::Configurable
  include Blacklight::SolrHelper
  include Ddr::Public::Controller::SolrQueryConstructor

  attr_accessor :document

  def initialize(args={})
    @document = args[:document]
  end

  def collection
    collection_search[1].first
  end

  def item
    item_search[1].first
  end

  def metadata_header
    "File Info"
  end

  private

  def collection_search
    puts "@@@@@ Component collection_search @@@@@"
    response, documents = get_search_results({ q: collection_query, rows: 10 })
  end

  def collection_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::ID, [document.admin_policy_uri])
    construct_query(field_pairs, "OR")
  end

  def item_search
    puts "@@@@@ Component item_search @@@@@"
    response, documents = get_search_results({ q: item_query, rows: 10 })
  end

  def item_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::ID, [document.is_part_of])
    construct_query(field_pairs, "OR")
  end

end
