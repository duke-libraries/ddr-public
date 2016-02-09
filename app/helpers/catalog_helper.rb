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
  
  def is_multi_image? document
    document.multires_image_file_paths.length > 1
  end

  # Facet field view helper
  # Also used in custom sort for collection facet
  def collection_title collection_internal_uri
    collections[collection_internal_uri]
  end
  
  def render_thumbnail_link document, size, counter = nil
    if thumbnail_multires_image_file_path = thumbnail_multires_image_file_path(document)
      thumbnail_link_to_document(document, thumbnail_multires_image_file_path, size, counter)
    else
      render_thumbnail_tag(document, {}, :counter => counter)
    end 
  end

  def collection_thumbnail_local_id(document)
    Rails.application.config.portal.try(:[] , 'portals').try(:[] , 'collection_local_id').try(:[] , document.local_id).try(:[] , 'thumbnail_image')
  end

  def collection_thumbnail_item_documents(document)
    thumbnail_documents = []
    if thumbnail_local_id = collection_thumbnail_local_id(document)
      response, thumbnail_documents = get_search_results({:q => "(#{Ddr::Index::Fields::LOCAL_ID}:#{thumbnail_local_id}) AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item"})
    end
    thumbnail_documents
  end

  def thumbnail_multires_image_file_path(document)
    multires_thumbnail_path = nil
    collection_item_documents = collection_thumbnail_item_documents(document)

    if collection_thumbnail_local_id(document) and collection_item_documents.length > 0
      multires_thumbnail_path = collection_item_documents.first.multires_image_file_paths.first
    elsif document.multires_image_file_path.present?
      multires_thumbnail_path = document.multires_image_file_path
    elsif document.multires_image_file_paths.present?
      multires_thumbnail_path = document.multires_image_file_paths.first
    end

    multires_thumbnail_path
  end

  def thumbnail_link_to_document(document, multires_image_file_path, size, counter)
    image_tag = iiif_image_tag(multires_image_file_path, {:size => size, :alt => 'Thumbnail', :class => 'img-thumbnail'})
    link_to_document document, image_tag, :counter => counter
  end

  def item_image_embed options={}
    image_tag = ""
    response, documents = get_search_results({:q => "(#{Ddr::Index::Fields::LOCAL_ID}:#{options[:local_id]}) AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item"})
    unless documents.empty?
      multires_image_file_path = documents.first.multires_image_file_paths.first
      image_tag = iiif_image_tag(multires_image_file_path, {:size => options[:size], :alt => documents.first.title, :class => options[:class]})
    end
    image_tag
  end

  def item_title_link options={}
    link = ""
    response, documents = get_search_results({:q => "(#{Ddr::Index::Fields::LOCAL_ID}:#{options[:local_id]}) AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item"})
    unless documents.empty?
      link = link_to_document(documents.first)
    end
    link
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

  # Index / Show field view helper
  def year_ranges options={}
    ranges = []
    years = []
    year_values = options[:value].first.split(";")
    year_values.each do |year_value|
      year_value.strip!
      if year_value.match(/^\d{4}$/)
        years << year_value
      else
        ranges << year_value
      end
    end
    if years.count > 1
      years.sort!
      ranges << years.first + "-" + years.last
    elsif years.count == 1
      ranges << years.first
    end
    ranges.sort!
    ranges.join("; ")
  end
  

  # Index / Show field view helper
  def display_edtf_date options={}
    if date = Date.edtf(options[:value].first)
      date.humanize
    else
      options[:value].first
    end
  end
  

  # Index / Show field view helper
  def source_collection options={}
    begin
      
      link_to options[:document].finding_aid.collection_title, options[:document].finding_aid.url, { data: { 
        toggle: 'popover', 
        placement: options[:placement] ? options[:placement] : 'top', 
        html: true, 
        title: ''+ image_tag("ddr/archival-box.png", :class=>"collection-guide-icon") + 'Source Collection Guide', 
        content: finding_aid_popover(options[:document].finding_aid)
      }}

    rescue OpenURI::HTTPError => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      fallback_link = link_to "Search Collection Guides", "http://library.duke.edu/rubenstein/findingaids/"
      "<p class='small'>" + fallback_link + "</p>"
    end
  end

  # Index / Show field view helper
  def language_display options={}
    display = []
    options[:value].each do |language_code|
      display << t("ddr.language_codes.#{language_code}", :default => language_code)
    end
    display.join("; ")
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
    unless research_help.name.blank?
      link_to_if(research_help.url, research_help.name, research_help.url)
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

  def find_collection_results
    response, document_list = get_search_results(add_facet_params(Ddr::Index::Fields::ACTIVE_FEDORA_MODEL, 'Collection', params.merge({rows: 21})))
    document_list
  end
  
  def get_blog_posts blog_url
    if blog_url.present?
      # NOTE: This URL has to be https. We get this data from Wordpress via the JSON API plugin.
      # We had to revise the query_images() function in json-api/models/attachment.php to
      # cirumvent a bug where image data was not rendering when hitting the API via https. 
      begin
        blog_posts = JSON.parse(open(blog_url,{ ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }).read)
      rescue OpenURI::HTTPError => e
        Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
        fallback_link = link_to "See All Blog Posts", "http://blogs.library.duke.edu/bitstreams"
        "<p class='small'>" + fallback_link + "</p>"
      end
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
