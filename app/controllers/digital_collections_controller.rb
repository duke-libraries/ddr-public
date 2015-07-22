# -*- encoding : utf-8 -*-
class DigitalCollectionsController < CatalogController

  before_filter -> { get_internal_uris_from_collection_identifiers ({:collection_identifiers => ["blake","wdukesons"]})}, only: [:index, :show]

  def about
    render 'about'
  end

  DigitalCollectionsController.solr_search_params_logic += [:include_only_digital_collections]

  configure_blacklight do |config|
    config.facet_fields.clear
    config.add_facet_field Ddr::IndexFields::COLLECTION_FACET, label: 'Collection', helper_method: 'collection_title', limit: 9999, collapse: false 
  end

  private

  # Alternately, use Ddr::IndexFields::ADMIN_SET Digital Collections scoping.
  def include_only_digital_collections(solr_parameters, user_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << construct_solr_parameter_value({:solr_field => Ddr::IndexFields::IS_GOVERNED_BY, :boolean_operator => "OR", :values => @internal_uris})
  end

end
