module DocumentModel::Searcher

  def searcher
    if document.controller_scope
      @search_builder ||= SearchBuilder.new(query_processor_chain, document.controller_scope)
    else
      search_builder
    end
  end

  def query_processor_chain
    [:add_query_to_solr, :apply_access_controls, :include_only_published]
  end

end
