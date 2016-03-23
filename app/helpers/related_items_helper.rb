module RelatedItemsHelper

  include Ddr::Public::Controller::ConstantizeSolrFieldName

  def related_item_documents options={}
    related_item_documents = {}
    options[:item_relators].each do |item_relator|
      relator_field = constantize_solr_field_name({solr_field: item_relator["field"]})
      solr_documents = facet_field_value_matches(options[:document].id, relator_field)
      unless solr_documents.blank?
        related_item_documents[item_relator['name']] = facet_field_value_matches(options[:document].id, relator_field)
      end
    end
    related_item_documents
  end

  private

  def facet_field_value_matches document_id, relator_field
    relator_field_values = relator_field_values(document_id, relator_field)
    unless relator_field_values.blank?
      relator_field_items = relator_field_values.map { |value| Item.where(relator_field => value) }
      related_items_solr_documents(document_id, relator_field_items)
    end
  end

  def related_items_solr_documents document_id, relator_field_items
    item_ids = relator_field_items.map{ |items| items.map { |item| item.id } - [document_id] }
    item_ids.first.map { |id| SolrDocument.find(id) }
  end

  def relator_field_values document_id, relator_field
    facet_values_and_counts = document_facet_field_values_and_counts(document_id, relator_field)
    Hash[*facet_values_and_counts].keys
  end

  def document_facet_field_values_and_counts document_id, solr_field
    response, docs = get_search_results(q: "id:\"#{document_id}\"", "facet.field" => solr_field, fl: "id")
    
    response['facet_counts']['facet_fields'][solr_field]
  end

end
