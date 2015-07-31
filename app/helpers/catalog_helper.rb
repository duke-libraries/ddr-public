module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # Facet field view helper
  # Also used in custom sort for collection facet
  def collection_title collection_internal_uri
    collections[collection_internal_uri]
  end

  # TODO: I can almost use this to get what I need to get the first child's thumbnail
  # For the index view. But the params need to be adjusted because either the  specified
  # controller or the facet filter breaks the query.
  # also, this method changes the value of @response that in turn messes up the paging 
  # on the index view.

  # View helper
  def find_children document, relationship
    configure_blacklight_for_children
    query = ActiveFedora::SolrService.construct_query_for_rel([[relationship, document[Ddr::IndexFields::INTERNAL_URI]]])
    @response, @document_list = get_search_results(params.merge(rows: 999999), {q: query})
  end

  # Index / Show field view helper
  def file_info options={}
    document = options[:document]
    if can? :download, document
      render partial: "download_link_and_icon", locals: {document: document}
    elsif document.effective_permissions([Ddr::Auth::Groups::REGISTERED]).include?(:download)
      render partial: "login_to_download", locals: {document: document}
    else
      render_content_type_and_size(document)
    end
  end

  # Index / Show field view helper
  def permalink options={}
    link_to options[:value], options[:value]
  end

  # Index / Show field view helper
  def descendant_of options={}
    pid = ActiveFedora::Base.pid_from_uri(options[:value].first)
    query = ActiveFedora::SolrService.construct_query_for_pids([pid])
    results = ActiveFedora::SolrService.query(query)
    docs = results.map { |result| SolrDocument.new(result) }
    titles = docs.map(&:title)
    if can? :read, docs.first
      link_to titles.first, url_for_document(docs.first)
    else
      titles.first
    end
  end

  def parent_abstract uri
    pid = ActiveFedora::Base.pid_from_uri(uri.first)
    query = ActiveFedora::SolrService.construct_query_for_pids([pid])
    results = ActiveFedora::SolrService.query(query)
    docs = results.map { |result| SolrDocument.new(result) }
    unless docs.first.abstract.blank?
      docs.first.abstract
    end
  end

  # View helper
  def render_content_type_and_size document
    "#{document.content_mime_type} #{document.content_size_human}"
  end

  # View helper
  def render_download_link args = {}
    return unless args[:document]
    label = args.fetch(:label, "Download")
    link_to label, download_path(args[:document]), class: args[:css_class], id: args[:css_id]
  end


  # View helper
  def research_help_title research_help
    unless research_help[:name].blank?
      link_to_if(research_help[:url], research_help[:name], research_help[:url])     
    end
  end


  # View helper
  def license_title effective_license
    if effective_license[:title].blank?
      effective_license[:title] = t("ddr.public.license_title")
    end
    if effective_license[:url].blank?
      link_to effective_license[:title], copyright_path
    else
      link_to effective_license[:title], effective_license[:url]
    end
  end

  def find_collection_results response
    collection_uris = response.facet_counts['facet_fields']['collection_facet_sim'].select.each_with_index { |str, i| i.even? }
    pids = collection_uris.map { |uri| ActiveFedora::Base.pid_from_uri(uri) }
    query = ActiveFedora::SolrService.construct_query_for_pids(pids)
    results = ActiveFedora::SolrService.query(query)
    docs = results.map { |result| SolrDocument.new(result) }
  end

  private

  def collections
    @collections ||=
      begin
        response, docs = get_search_results(q: "active_fedora_model_ssi:Collection",
                                            fl: "internal_uri_ssi,title_ssi",
                                            rows: 9999)
        docs.each_with_object({}) do |doc, memo|
          memo[doc["internal_uri_ssi"]] = doc["title_ssi"]
        end
      end
  end

end
