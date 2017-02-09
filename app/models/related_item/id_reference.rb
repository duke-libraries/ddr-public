class RelatedItem::IdReference

  include RelatedItem::RelatedItemBehavior


  private

  def solr_field_name
    constantize_solr_field_name({solr_field: @config["field"]})
  end

  def solr_query_field
    constantize_solr_field_name({solr_field: @config["id_field"]})
  end

  def solr_query_values
    "\"#{document_field_values.join(' OR ')}\"" if document_field_values.present?
  end

  def title_sorted_documents
    if document_field_values.present?
      response = repository.search(search_builder.where(id_field_query).merge(sort: sort))
      response.documents
    end
  end

  def id_field_query
    construct_query(field_value_pairs(solr_query_field, document_field_values), 'OR')
  end

  def document_field_values
    @document[solr_field_name]
  end

end
