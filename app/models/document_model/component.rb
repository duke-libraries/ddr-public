class DocumentModel::Component

  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Ddr::Public::Controller::SolrQueryConstructor
  include DocumentModel::Searcher
  include DocumentModel::HtmlTitle

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

  def html_title
    html_title = []
    html_title += [ document.title.truncate(150) +
                    html_title_qualifier(document.title, document.permanent_id ? document.permanent_id : document.public_id),
                    item.title.truncate(100),
                    I18n.t('blacklight.application_name') ]
    html_title.join(' / ')
  end

  private

  def collection_search
    query = searcher.where(collection_query)
    repository.search(query)
  end

  def collection_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::INTERNAL_URI, [document.collection_uri])
    construct_query(field_pairs, "OR")
  end

  def item_search
    query = searcher.where(item_query)
    repository.search(query)
  end

  def item_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::INTERNAL_URI, [document.is_part_of])
    construct_query(field_pairs, "OR")
  end

end
