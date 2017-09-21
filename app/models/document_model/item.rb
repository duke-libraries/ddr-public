class DocumentModel::Item

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

  def parent_directories
    if dir_and_sibling_hash_from_collection
      dir_and_sibling_hash_from_collection[:parent_directories]
    end
  end

  def directory_siblings
    if dir_and_sibling_hash_from_collection
      dir_sibling_search.documents.sort { |a,b| a.title <=> b.title }
    end
  end

  def html_title
    html_title = []
    html_title += [ document.title.truncate(150) +
                    html_title_qualifier(document.title, document.permanent_id ? document.permanent_id : document.public_id),
                    collection.title.truncate(100),
                    I18n.t('blacklight.application_name') ]
    html_title.join(' / ')
  end

  private

  def dir_and_sibling_hash_from_collection
    collection.structures.directories.item_pid_lookup[document.pid]
  end

  def directory_sibling_pids
    dir_and_sibling_hash_from_collection[:files] if dir_and_sibling_hash_from_collection
  end

  def dir_sibling_search
    query = searcher.where(dir_sibling_query).merge({rows: 1000})
    repository.search(query)
  end

  def dir_sibling_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::ID, directory_sibling_pids)
    construct_query(field_pairs, "OR")
  end

  def collection_search
    query = searcher.where(collection_query)
    repository.search(query)
  end

  def collection_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::INTERNAL_URI, [document.parent_uri])
    construct_query(field_pairs, "OR")
  end

  def component_search
    query = searcher.where(component_query).merge({rows: 2000})
    repository.search(query)
  end

  def component_query
    field_pairs = field_value_pairs(Ddr::Index::Fields::IS_PART_OF, [document.internal_uri])
    construct_query(field_pairs, "OR")
  end

end
