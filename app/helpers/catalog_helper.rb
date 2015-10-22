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
  
  def render_thumbnail_link document, size, counter = nil
    path = multires_thumbnail_path(document)
    if path.present?
      thumbnail_link_to_document(document, path, size, counter)
    else
      render_thumbnail_tag(document, {}, :counter => counter)
    end 
  end

  def multires_thumbnail_path(document)
    thumbnail_path = nil
    if document.multires_image_file_paths.present?
      thumbnail_path = document.multires_image_file_paths.first
    elsif document.multires_image_file_path.present?
      thumbnail_path = document.multires_image_file_path
    else
      response, child_documents = find_children(document)
      if child_documents.present?
        multires_thumbnail_path(child_documents.first)
      end
    end
  end

  def thumbnail_link_to_document(document, multires_image_file_path, size, counter)
    image_tag = iiif_image_tag(multires_image_file_path, {:size => size, :alt => 'Thumbnail', :class => 'img-thumbnail'})
    link_to_document document, image_tag, :counter => counter
  end


  def find_children document, relationship = nil, params = {}
    configure_blacklight_for_children
    relationship ||= find_relationship(document)

    query = ActiveFedora::SolrService.construct_query_for_rel([[relationship, document[Ddr::Index::Fields::INTERNAL_URI]]])
    response, document_list = get_search_results(params.merge(rows: 99999), {q: query}) # allow params

    return response, document_list
  end
  
  def item_count pid
    Item.where("is_governed_by_ssim"=>"info:fedora/#{pid}").count
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
    unless document[Ddr::Index::Fields::ADMIN_SET].blank?
      document[Ddr::Index::Fields::ADMIN_SET]
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
  def search_scope_dropdown current_search_scopes = nil
    all_search_scopes = all_search_scopes()

    if current_search_scopes.present?
      current_search_scope_options = []
      current_search_scopes.each do |scope_name|
        current_search_scope_options << all_search_scopes[scope_name]
      end
      render partial: "search_scope_dropdown", locals: {current_search_scope_options: current_search_scope_options}
    end

  end
  
  def finding_aid_popover finding_aid
    popover = ''
    if finding_aid.collection_title
      popover << '<h4>' + finding_aid.collection_title + faid_date_span(finding_aid) + '</h4>'
    end
    if finding_aid.collection_number || finding_aid.extent
      popover << '<p class="small text-muted">' + faid_collno_and_extent(finding_aid) + '</p><hr/>'
    end
    if finding_aid.abstract
      popover << '<p class="small">' + finding_aid.abstract.truncate(250, separator: ' ') + '</p>'
    end
    if finding_aid.repository
      popover << '<div class="small well well-sm">View this item in person at:<br/>' + finding_aid.repository + '</div>'
    end
    return popover
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
  

  def get_blog_posts slug
    if Rails.application.config.portal_controllers['collections'][slug] && Rails.application.config.portal_controllers['collections'][slug]['blog_posts']
      
        # NOTE: This URL has to be https. We get this data from Wordpress via the JSON API plugin.
        # We had to revise the query_images() function in json-api/models/attachment.php to
        # cirumvent a bug where image data was not rendering when hitting the API via https. 

        blog_posts = JSON.parse(open(Rails.application.config.portal_controllers['collections'][slug]['blog_posts'],{ ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }).read)
      
    end
  end
  
  def blog_post_thumb post
    
    # If a post has a selected "featured image", use that.
    if post['thumbnail_images'] && post['thumbnail_images']['thumbnail']
      post['thumbnail_images']['thumbnail']['url']
      
    # If a post has no selected "featured image", but does have an image in it, use the first image's thumb
    elsif post['attachments'] && post['attachments'][0] && post['attachments'][0]['images'] && post['attachments'][0]['images']['thumbnail']
      post['attachments'][0]['images']['thumbnail']['url']
      
    # If imageless, use a generic thumb
    else
      image_path('ddr/devillogo-150-square.jpg')
    end
    
  end
  
  


  private

  def all_search_scopes
    {:search_action_url => ["This Collection", search_action_url],
     :digital_collections => ["Digital Collections", digital_collections_url],
     :catalog_index_url => ["Digital Repository", catalog_index_url]}
  end

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
  
  def faid_date_span finding_aid
    if finding_aid.collection_date_span
      return ' <span class="small text-muted">'+ finding_aid.collection_date_span+'</span>'
    end
  end
  
  def faid_collno_and_extent finding_aid  
    section = ''
    section << '<p class="small text-muted">'
    if finding_aid.collection_number
      section << 'Collection #' + finding_aid.collection_number
    end
    if finding_aid.extent
      section << '<br/>' + finding_aid.extent
    end
    section << '</p>'
    return section  
  end

end
