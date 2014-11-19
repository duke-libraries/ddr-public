module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def collection_title value
    Collection.find(value.split('/').last).title_display
  end

  def find_children document, relationship
    configure_blacklight_for_children
    query = ActiveFedora::SolrService.construct_query_for_rel([[relationship, document[Ddr::IndexFields::INTERNAL_URI]]])
    @response, @document_list = get_search_results(params, {q: query})
  end

  def render_content_type_and_size(document)
      "#{document.content_mime_type} #{document.content_size_human}"
  end
    
  def render_download_link(args = {})
    return unless args[:document]
    label = args.fetch(:label, "Download")
    link_to label, download_path(args[:document]), class: args[:css_class], id: args[:css_id]
  end
  
  def render_download_icon(args = {})
    label = content_tag(:span, "", class: "glyphicon glyphicon-download-alt")
    render_download_link args.merge(label: label)
  end

end