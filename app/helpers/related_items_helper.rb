module RelatedItemsHelper

  def related_item_documents document
    related_item_documents = document.item_relators.map do |item_relator|
      relator_field = constantize_solr_field_name({solr_field: item_relator["field"]})
      solr_documents = facet_field_value_matches(document.id, relator_field)
      unless solr_documents.blank?
        { item_relator['name'] => solr_documents }
      end
    end
    related_item_documents.reduce(:merge) || {}
  end

  private

  def facet_field_value_matches document_id, relator_field
    relator_field_values = relator_field_values(document_id, relator_field)
    unless relator_field_values.blank?
      relator_field_items = relator_field_values.map { |value| relator_field_query(relator_field, value) }
      related_items_solr_documents(document_id, relator_field_items)
    end
  end

  def relator_field_query relator_field, value
    puts "@@@@@ relator_field_query @@@@@"
    query = construct_query(relator_field => value)
    response, documents = get_search_results({ :q => query })
    documents
  end

  def related_items_solr_documents document_id, relator_field_items
    items = relator_field_items.map{ |items| items.delete_if { |item| item['id'] == document_id } }
    items.first.map { |item| SolrDocument.new(item) }
  end

  def relator_field_values document_id, relator_field
    facet_values_and_counts = document_facet_field_values_and_counts(document_id, relator_field)
    Hash[*facet_values_and_counts].keys
  end

  def document_facet_field_values_and_counts document_id, solr_field
    puts "@@@@@ document_facet_field_values_and_counts @@@@@"
    query = ActiveFedora::SolrService.construct_query_for_ids([document_id])
    response, docs = get_search_results(q: query, "facet.field" => solr_field, fl: "id")
    response['facet_counts']['facet_fields'][solr_field]
  end

end
