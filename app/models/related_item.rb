class RelatedItem

  include Blacklight::Configurable
  include Blacklight::SearchHelper
  include Ddr::Public::Controller::SolrQueryConstructor

  attr_accessor :document,
                :config,
                :related_documents,
                :name,
                :solr_field,
                :solr_values,
                :solr_params

  def initialize args={}
    @document   = args[:document]
    @config     = args[:config]
    @name       = relation_name
    @solr_field = solr_field_name
  end

  def solr_values
    @values ||= Hash[*facet_values_and_counts].keys
  end

  def related_documents
    @rel_docs ||= title_sorted_documents
  end

  def solr_params
    {"f" => {@solr_field => self.solr_values}, "sort" => "#{Ddr::Index::Fields::TITLE} asc"}
  end


  private

  def title_sorted_documents
    delete_self.sort { |a,b| a.title <=> b.title }
  end

  def delete_self
    remove_duplicates.delete_if { |doc| doc.id == @document.id }
  end

  def remove_duplicates
    related_documents_results.flatten.uniq { |doc| doc.id }
  end

  def related_documents_results
    self.solr_values.map do |value|
      relator_field_query(@solr_field, value)
    end
  end

  def relation_name
    @config["name"]
  end

  def solr_field_name
    constantize_solr_field_name({solr_field: @config["field"]})
  end

  def relator_field_query relator_field, value
    query = construct_query(relator_field => value)
    response = repository.search(search_builder.where(query))
    response.documents
  end

  def facet_values_and_counts
    query = ActiveFedora::SolrService.construct_query_for_pids([@document.id])
    response = repository.search(searcher.where(query).merge({fl: "id", 'facet.field' => @solr_field}))
    response['facet_counts']['facet_fields'][@solr_field]
  end

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
