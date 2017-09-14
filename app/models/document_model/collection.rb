class DocumentModel::Collection

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

  def html_title
    html_title = []
    html_title += [document.title.truncate(150)]
    if document[Ddr::Index::Fields::ADMIN_SET_TITLE].present?
      html_title += [document[Ddr::Index::Fields::ADMIN_SET_TITLE].truncate(100)]
    end
    html_title += [I18n.t('blacklight.application_name')]
    html_title.join(' / ')
  end

  private

  def items_search
    query = searcher.where(items_query).merge({rows: 10})
    repository.search(query)
  end

  def items_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::IS_MEMBER_OF_COLLECTION, [document.internal_uri])
    construct_query(field_pairs, "OR")
  end

end
