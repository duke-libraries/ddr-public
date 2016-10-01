class DocumentModel::Item

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

  def components
    component_search.documents
  end

  def component_count
    component_search.total
  end

  def metadata_header
    case document.display_format
    when 'folder'
      'Folder Info'
    end
  end

  private

  def collection_search
    query = searcher.query({ q: collection_query, rows: '10' })
    repository.search(query)
  end

  def collection_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::INTERNAL_URI, [document.parent_uri])
    construct_query(field_pairs, "OR")
  end

  def component_search
    query = searcher.query({ q: component_query, rows: '10000' })
    repository.search(query)
  end

  def component_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::IS_PART_OF, [document.internal_uri])
    construct_query(field_pairs, "OR")
  end

end
