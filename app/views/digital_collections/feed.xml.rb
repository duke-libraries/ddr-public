feed_mapping = field_value_mappings({
  field_configs: Rails.application.config.dpla_mapping[:dpla_fields],
  document: @document
})

namespaces = {
"xmlns:dul_dc" => "#{root_url}schemas/dul_dc/",
"xmlns:dc" => "http://purl.org/dc/elements/1.1/",
"xmlns:dcterms" => "http://purl.org/dc/terms/",
"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance",
"xsi:schemaLocation" => "#{root_url}schemas/dul_dc/ #{root_url}schemas/dul_dc.xsd"
}

builder = Nokogiri::XML::Builder.new do |xml|
  xml.dc(namespaces) {
    feed_mapping.each do |mappings|
      xml[mappings[:namespace]].send("#{mappings[:dpla_field]}_", mappings[:duke_value])
    end
    xml.parent.namespace = xml.parent.namespace_definitions.find{|ns|ns.prefix=="dul_dc"}
  }
end

builder.to_xml
