module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  # Predicate methods for object types
  def is_item? document
    document[:active_fedora_model_ssi] == "Item"
  end
  
  def is_component? document
    document[:active_fedora_model_ssi] == "Component"
  end
  
  def is_collection? document
    document[:active_fedora_model_ssi] == "Collection"
  end 
  
  def is_multi_image? document, document_list
    image_item_tilesources(document, document_list).length > 1
  end       

  # Facet field view helper
  # Also used in custom sort for collection facet
  def collection_title collection_internal_uri
    collections[collection_internal_uri]
  end

  def render_thumbnail_tag_from_multires_image document, size, counter = nil
    if is_component?(document)
      choose_thumbnail document, document.multires_image_file_path, size, counter = nil
    elsif is_item?(document)
      response, document_list = find_children(document)
      choose_thumbnail document, document_list.first.multires_image_file_path, size, counter = nil
    elsif is_collection?(document)
      response, documents = find_children(document)
      response, document_list = find_children(documents.first)
      choose_thumbnail document, document_list.first.multires_image_file_path, size, counter = nil
    else
      render_thumbnail_tag(document, {}, :counter => counter)
    end
  end

  def choose_thumbnail document, multires_image_file_path, size, counter
    unless multires_image_file_path.blank?
      image_tag = iiif_image_tag(multires_image_file_path, {:size => size, :alt => 'Thumbnail', :class => 'img-thumbnail'})
      link_to_document document, image_tag, :counter => counter
    else
      render_thumbnail_tag(document, {}, :counter => counter)
    end
  end

  def find_children document, relationship = nil, params = {}
    configure_blacklight_for_children
    relationship ||= find_relationship(document)

    query = ActiveFedora::SolrService.construct_query_for_rel([[relationship, document[Ddr::IndexFields::INTERNAL_URI]]])
    response, document_list = get_search_results(params.merge(rows: 99999), {q: query}) # allow params

    return response, document_list
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
      link_to_document(docs.first)
    else
      titles.first
    end
  end

  def abstract_from_uri uri
    document = document_from_uri(uri.first)
    unless document.abstract.blank?
      document.abstract
    end
  end

  def local_id_from_uri uri
    document = document_from_uri(uri.first)
    unless document.local_id.blank?
      document.local_id
    end
  end

  def admin_set_from_uri uri
    document = document_from_uri(uri.first)
    unless document[Ddr::IndexFields::ADMIN_SET].blank?
      document[Ddr::IndexFields::ADMIN_SET]
    end
  end    

  def document_from_uri uri
    pid = ActiveFedora::Base.pid_from_uri(uri)
    query = ActiveFedora::SolrService.construct_query_for_pids([pid])
    results = ActiveFedora::SolrService.query(query)
    document_list = results.map { |result| SolrDocument.new(result) }
    document_list.first
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
    if response.facet_counts['facet_fields'].has_key?('collection_facet_sim')
      collection_uris = response.facet_counts['facet_fields']['collection_facet_sim'].select.each_with_index { |str, i| i.even? }
      pids = collection_uris.map { |uri| ActiveFedora::Base.pid_from_uri(uri) }
      query = ActiveFedora::SolrService.construct_query_for_pids(pids)
      results = ActiveFedora::SolrService.query(query)
      docs = results.map { |result| SolrDocument.new(result) }
    else
      docs = []
    end
  end

  private

  def find_relationship document
    if document.active_fedora_model == 'Item'
      relationship = :is_part_of
    elsif document.active_fedora_model == 'Collection'
      relationship = :is_member_of_collection
    else
      return
    end
  end

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
