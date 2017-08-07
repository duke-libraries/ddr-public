class DirectoryTreeController < CatalogController

  include BlacklightHelper

  def show
    if document[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL] == 'Collection'
      render json: fetch_links_and_titles
    elsif document[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL] == 'Item'
      render json: item_parent_directories_and_siblings
    end
  end

  private

  def item_parent_directories_and_siblings
    item_directory_list(document.parent_directories, document.directory_siblings)
  end

  def item_directory_list(directories=[], siblings=[])
    return [] if directories.blank?
    directories.map do |dir|
      { text: directories.shift,
        icon: 'fa fa-folder',
        state: { opened: true },
        a_attr: { href: 'javascript:void(0);' },
        children: (directories.blank? ? item_siblings_list(siblings) : item_directory_list(directories, siblings))
      }
    end
  end

  def item_siblings_list(siblings)
    siblings.map do |sib|
      select_state = sib.id == document.id ? true : false
      { id: sib.id,
        text: sib.title,
        icon: 'fa fa-file-o',
        state: { selected: select_state },
        a_attr: { href: document_or_object_url(sib) } }
    end
  end

  def fetch_links_and_titles
    directory.map do |item|
      if item.has_key?(:repo_id)
        doc = search_for_solr_document(item[:repo_id])
        if doc.present?
          { id: doc.id, text: doc.title, a_attr: { href: document_or_object_url(doc) }, icon: 'fa fa-file-o' }
        else
           nil
        end
      else
        item
      end
    end.compact
  end

  def directory
    directories[params[:directory_id]]
  end

  def directories
    @directories ||= document.structures.directories.directory_id_lookup
  end

  def document
    @document ||= SolrDocument.find(params[:id])
  end

  def search_for_solr_document(doc_id)
    response = repository.search(search_builder.where(solr_document_query(doc_id)))
    response.documents.first
  end

  def solr_document_query(doc_id)
    "id:#{doc_id}"
  end
end
