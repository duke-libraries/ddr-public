module ShowFeedHelper

  include Ddr::Public::Controller::ConstantizeSolrFieldName

  def field_value_mappings options={}
    feed_to_duke_value_mapping = []

    options[:field_configs].each do |feed_field, local_fields|
      namespace, field = feed_field.to_s.split(':')
      local_fields.each do |local_field|
        values = field_values({ local_field: local_field, document: options[:document] })

        Array(values).each do |value|
          if value
            feed_to_duke_value_mapping << field_value_mapping({ field: field, namespace: namespace, value: value })
          end
        end

      end
    end

    feed_to_duke_value_mapping
  end

  private

  def field_values options={}
    case
    when options[:local_field].has_key?(:solr_field)
      solr_field_value ({ helper_method: options[:local_field][:helper_method], solr_field: options[:local_field][:solr_field], document: options[:document] })
    when options[:local_field].has_key?(:document_helper)
      document_helper_value ({ helper_method: options[:local_field][:document_helper], document: options[:document] })
    when options[:local_field].has_key?(:value)
      value({ value: options[:local_field][:value] })
    end
  end

  def field_value_mapping options={}
    { dpla_field: options[:field], namespace: options[:namespace], duke_value: options[:value] }
  end

  def document_helper_value options={}
    send options[:helper_method], options[:document]
  end

  def solr_field_value options={}
    solr_field_name = constantize_solr_field_name({ solr_field: options[:solr_field] })
    values = options[:document][solr_field_name.to_s]

    if options[:helper_method] and values
      values = send options[:helper_method].to_s, { value: values }
    end

    values
  end

  def value options={}
    options[:value]
  end

end
