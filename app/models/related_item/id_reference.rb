class RelatedItem::IdReference

  include RelatedItem::RelatedItemBehavior

  def solr_query
     if solr_query_values.present?
      {"id_related_items" => "#{@document.id}|#{source_solr_field}|#{target_solr_field}",
       "sort" => sort,
       "q" => "",
       "search_field" => "all_fields"}
    end
  end

  private

  def source_solr_field
    @source_solr_field ||= constantize_solr_field_name({solr_field: @config["field"]})
  end

  def target_solr_field
    @target_solr_field ||= constantize_solr_field_name({solr_field: @config["id_field"]})
  end

  def solr_query_values
    @solr_query_values ||= "#{document_field_values.join(',')}" if document_field_values.present?
  end

  def title_sorted_documents
    solr_response.documents if solr_response
  end

  def document_count
    solr_response.total.to_i if solr_response
  end

  def solr_response
    if document_field_values.present?
      @solr_response ||= repository.search(search_builder.where(id_field_query).merge(sort: sort))
    end
  end

  def id_field_query
    construct_query(field_value_pairs(target_solr_field, document_field_values), 'OR')
  end

  def document_field_values
    @document[source_solr_field]
  end

end
