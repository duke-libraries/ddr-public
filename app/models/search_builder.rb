class SearchBuilder < Blacklight::Solr::SearchBuilder

  include Ddr::Models::SearchBuilder

  def include_only_published(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << "#{Ddr::Index::Fields::WORKFLOW_STATE}:published"
  end

end
