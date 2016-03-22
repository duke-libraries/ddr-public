module RelatedItemsHelper

  include Ddr::Public::Controller::ConstantizeSolrFieldName

  def related_item_documents options={}
    options[:item_relators].map do |item_relator|
      relator_field = constantize_solr_field_name({solr_field: item_relator["field"]})
      { item_relator['name'] => facet_field_value_matches(options[:document].id, relator_field)}
    end
  end

  private

  def facet_field_value_matches document_id, relator_field
    facet_values_and_counts = document_facet_field_values_and_counts(document_id, relator_field)
    relator_field_values = Hash[*facet_values_and_counts].keys
    relator_field_items = relator_field_values.map { |value| Item.where(relator_field => value) }
    item_ids = relator_field_items.map{ |items| items.map { |item| item.id } - [document_id] }
    item_ids.first.map { |id| SolrDocument.find(id) }
  end

  def document_facet_field_values_and_counts document_id, solr_field
    response, docs = get_search_results(q: "id:\"#{document_id}\"", "facet.field" => solr_field, fl: "id")
    
    response['facet_counts']['facet_fields'][solr_field]
  end

end
