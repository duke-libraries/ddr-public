class RelatedItem::SharedValue

  include RelatedItem::RelatedItemBehavior

  def solr_query
    {"f" => { solr_query_field => solr_query_values }, "sort" => sort} if solr_query_values.present?
  end

  private

  def solr_query_field
    constantize_solr_field_name({solr_field: @config["field"]})
  end

  def solr_query_values
    @values ||= Hash[*facet_values_and_counts].keys
  end

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
    solr_query_values.map do |value|
      relator_field_query(solr_query_field, value)
    end
  end

  def relator_field_query relator_field, value
    query = construct_query(relator_field => value)
    response = repository.search(search_builder.where(query))
    response.documents
  end

  def facet_values_and_counts
    query = ActiveFedora::SolrService.construct_query_for_pids([@document.id])
    response = repository.search(searcher.where(query).merge({fl: "id", 'facet.field' => solr_query_field}))
    response['facet_counts']['facet_fields'][solr_query_field]
  end

end
