class DocumentModel::Item

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

  def components
    component_search[1]
  end

  def component_count
    component_search[0].total
  end


  private

  def collection_search
    response, documents = get_search_results({ q: collection_query, rows: 10 })
  end

  # TODO: Define query in SolrQueryConstructor
  def collection_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::ID, [document.parent_uri])
    construct_query(field_pairs, "OR")
  end

  def component_search
    response, documents = get_search_results({ q: component_query, rows: 10000 })
  end

  # TODO: Define query in SolrQueryConstructor
  def component_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::IS_PART_OF, [document.id])
    construct_query(field_pairs, "OR")
  end

end
