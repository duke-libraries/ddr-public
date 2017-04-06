module RelatedItem::RelatedItemBehavior

  extend ActiveSupport::Concern

  included do
    include Blacklight::Configurable
    include Blacklight::SearchHelper
    include Ddr::Public::Controller::SolrQueryConstructor
  end


  def initialize args={}
    @document = args[:document]
    @config   = args[:config]
  end

  def name
    @config["name"]
  end

  def related_documents
    @rel_docs ||= title_sorted_documents
  end

  def solr_query
    {"f" => { solr_query_field => solr_query_values }, "sort" => sort} if solr_query_values.present?
  end


  private

  def sort
    "#{Ddr::Index::Fields::TITLE} asc"
  end

  def searcher
    if @document.controller_scope
      @search_builder ||= SearchBuilder.new(query_processor_chain, @document.controller_scope)
    else
      search_builder
    end
  end

  def query_processor_chain
    [:add_query_to_solr, :apply_access_controls, :include_only_published]
  end

end
