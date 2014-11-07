module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def collection_title value
    Collection.find(value.split('/').last).title_display
  end

  def find_children document, relationship
    configure_blacklight_for_children
    query = ActiveFedora::SolrService.construct_query_for_rel([[relationship, document[Ddr::IndexFields::INTERNAL_URI].first]])
    @response, @document_list = get_search_results(params, {q: query})
  end

end