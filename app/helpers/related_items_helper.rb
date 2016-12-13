module RelatedItemsHelper

  def related_item_documents document
    related_item_documents = document.item_relators.map do |item_relator|
      relator_field = constantize_solr_field_name({solr_field: item_relator["field"]})
      solr_documents = field_value_document_matches(document.id, relator_field)
      unless solr_documents.blank?
        { item_relator['name'] => solr_documents }
      end
    end
    related_item_documents.compact.reduce({}, :merge)
  end

  private

  def field_value_document_matches document_id, relator_field
    relator_field_values = relator_field_values(document_id, relator_field)
    unless relator_field_values.blank?
      all_related_documents = relator_field_values.map { |value| relator_field_query(relator_field, value) }
      remove_document_by_id(document_id, all_related_documents)
    end
  end

  def relator_field_values document_id, relator_field
    facet_values_and_counts = document_facet_field_values_and_counts(document_id, relator_field)
    Hash[*facet_values_and_counts].keys
  end

  def relator_field_query relator_field, value
    query = construct_query(relator_field => value)
    response = repository.search(search_builder.where(query))
    response.documents
  end

  # Removes any SolrDocument in the all_related_documents array if it
  # matches the supplied document ID.
  def remove_document_by_id document_id, all_related_documents
    documents = all_related_documents.map{ |items| items.delete_if { |item| item['id'] == document_id } }
    documents.first.map { |item| SolrDocument.new(item) }
  end

  # Queries Solr for a document by id and returns the solr field matches and counts
  # for the specified facet field.
  def document_facet_field_values_and_counts document_id, solr_field
    query = ActiveFedora::SolrService.construct_query_for_pids([document_id])
    response = repository.search(search_builder.where(query).merge({fl: "id", 'facet.field' => solr_field}))
    response['facet_counts']['facet_fields'][solr_field]
  end

end
