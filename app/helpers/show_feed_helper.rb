module ShowFeedHelper

  def field_value_mappings options={}
    mappings = options[:field_configs].map do |feed_field, local_fields|
      map_local_fields(feed_field, local_fields, options[:document])
    end
    mappings.flatten
  end

  private

  def map_local_fields(feed_field, local_fields, document)
    local_fields.map { |local_field| map_values(feed_field, local_field, document) }
  end

  def map_values(feed_field, local_field, document)
    values_array(local_field, document).map do |value|
      { dpla_field: field(feed_field), namespace: namespace(feed_field), duke_value: value }
    end
  end

  def values_array(local_field, document)
    Array(field_values(local_field,document))
  end

  def namespace(feed_field)
    feed_field.to_s.split(':')[0]
  end

  def field(feed_field)
    feed_field.to_s.split(':')[1]
  end

  def field_values(local_field, document)
    case local_field.map { |key, value| key }.first
    when :solr_field
      solr_field_value(local_field[:helper_method], local_field[:solr_field], document)
    when :document_helper
      send local_field[:document_helper], document
    when :value
      local_field[:value]
    end
  end

  def solr_field_value(helper_method, solr_field, document)
    solr_field_name = constantize_solr_field_name({ solr_field: solr_field })
    values = document[solr_field_name.to_s]

    if helper_method and values
      values = send helper_method.to_s, { value: values }
    end

    values
  end

end
