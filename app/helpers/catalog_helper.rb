module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # Facet field view helper
  def collection_title value
    Collection.find(value.split('/').last).title_display
  end

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
    elsif !user_signed_in? && document.principal_has_role?(["registered", Ddr::Auth::RemoteGroupService::AFFILIATION_GROUP_MAP.values].flatten, :downloader)
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

end
