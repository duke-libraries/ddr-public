class SearchBuilder < Blacklight::Solr::SearchBuilder

  include Ddr::Models::SearchBuilder

  def include_only_published(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Ddr::Index::Fields::WORKFLOW_STATE}:published"
  end

  def include_only_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Collection"
  end

  def include_only_items(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item"
  end

  def filter_by_parent_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << scope.filter_by_parent_collections_query
  end

end
