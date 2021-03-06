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

  def has_two_or_more_multires_images? document
    document.multires_image_file_paths.present? && document.multires_image_file_paths.length > 1
  end

  # Facet field view helper
  # Also used in custom sort for collection facet
  def collection_title collection_internal_uri
    collections[collection_internal_uri]
  end

  def item_image_embed options={}
    image_tag = ""
    response = repository.search(search_builder.where("#{Ddr::Index::Fields::LOCAL_ID}:#{options[:local_id]}").append(:include_only_items))
    unless response.empty?
      multires_image_file_path = response.documents.first.multires_image_file_paths.first
      image_tag = iiif_image_tag(multires_image_file_path, {:size => options[:size], :alt => response.documents.first.title, :class => options[:class]})
    end
    image_tag
  end

  # TODO: use solr query concerns
  def item_title_link options={}
    link = ""
    response = repository.search(search_builder.where("#{Ddr::Index::Fields::LOCAL_ID}:#{options[:local_id]}").append(:include_only_items))
    unless response.empty?
      link = link_to_document(response.documents.first)
    end
    link
  end

  # View helper: from EITHER collection show page or configured collection portal, browse items.
  def collection_browse_items_url document, options={}
    if @portal
      search_action_url(add_facet_params(Ddr::Index::Fields::ACTIVE_FEDORA_MODEL, 'Item'))
    else
      search_action_url(add_facet_params(Ddr::Index::Fields::ACTIVE_FEDORA_MODEL, 'Item', 
        params.merge("f[#{Ddr::Index::Fields::COLLECTION_TITLE}][]" => document[Ddr::Index::Fields::COLLECTION_TITLE],
                     "f[#{Ddr::Index::Fields::ADMIN_SET_TITLE}][]" => document[Ddr::Index::Fields::ADMIN_SET_TITLE])))
    end
  end

  def item_browse_components_url document, options={}
    search_action_url(add_facet_params(Ddr::Index::Fields::IS_PART_OF, document.internal_uri))
  end

  # Index / Show field view helper
  def file_info options={}
    document = options[:document]
    if can? :download, document
      render partial: "download_link_and_icon", locals: { document: document }
    else
      if user_signed_in?
        render partial: "download_not_authorized", locals: { document: document }
      else
        render partial: "download_restricted", locals: { document: document }
      end
    end
  end

  # View helper
  def render_download_link args = {}
    return unless args[:document]
    label = icon("download", "Download")
    link_to label, download_path(args[:document]), class: args[:css_class], id: args[:css_id], data: args[:data]
  end

  # View helper
  def default_mime_type_label(mime_type)
    case mime_type
    when /^image/
      'Image'
    when /^video/
      'Video'
    when /^audio/
      'Audio'
    when /^application\/(x-)?pdf/
      'PDF'
    when /^application/
      'Binary'
    when /^text\/comma-separated-values/
      'CSV'
    else
      'File'
    end
  end


  def get_finding_aid(document)
    begin
      Timeout.timeout(2) do
        fa = document.finding_aid
        document.finding_aid.title if fa
        fa
      end
    rescue => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      false
    end
  end


  def get_research_help(document)
    begin
      Timeout.timeout(2) do
        document.research_help
      end
    rescue => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      false
    end
  end

  # View helper
  def research_help_title research_help
    unless research_help.name.blank?
      link_to_if(research_help.url, research_help.name, research_help.url)
    end
  end

  # View helper
  def render_search_scope_dropdown params={}
    active_search_scopes = []

    if request.path =~ /^\/dc.*$/ && params[:collection].present?
      active_search_scopes << ["This Collection", digital_collections_url(params[:collection])]
    end

    if request.path =~ /^\/dc.*$/
      active_search_scopes << ["Digital Collections", digital_collections_index_portal_url]
    end

    if request.path =~ /^\/portal.*$/ && params[:collection].present?
      active_search_scopes << ["This Portal", portal_url(params[:collection])]
    end

    if request.path =~ /^\/portal.*$/
      active_search_scopes << ["All Portals", portal_index_portal_url]
    end

    active_search_scopes << ["Digital Repository", catalog_index_url]

    if active_search_scopes.count > 1
      render partial: "search_scope_dropdown", locals: {active_search_scope_options: active_search_scopes}
    end
  end

  # View helper
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
    response = repository.search(search_builder.with(params).append(:include_only_collections))
    {documents: response.documents, count: response.total}
  end

  def get_blog_posts blog_url
    if blog_url.present?
      # NOTE: This URL has to be https. We get this data from Wordpress via the JSON API plugin.
      # We had to revise the query_images() function in json-api/models/attachment.php to
      # cirumvent a bug where image data was not rendering when hitting the API via https.
      begin
        blog_posts = JSON.parse(open(blog_url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE, read_timeout: 2 }).read)
      rescue Net::ReadTimeout, OpenURI::HTTPError => e
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

  def link_to_admin_set document, options={}
    name = document[Ddr::Index::Fields::ADMIN_SET_TITLE]
    url =  facet_search_url(Ddr::Index::Fields::ADMIN_SET_TITLE, name)
    link_to name, url, :class => options[:class], :id => "admin-set"
  end

  def research_guide values=[]
    values.select { |value| is_research_guide? value }.first if values.present?
  end

  # DPLA Feed document helper
  def source_collection_title document
    document.try(:finding_aid).try(:collection_title)
  end

  # DPLA Feed document helper
  def research_help_name document
    document.try(:research_help).try(:name)
  end

  def derivative_urls document
    if document.derivative_url_prefixes.present?
      ActiveSupport::Deprecation.warn("Support for external AV derivatives via derivative_urls is deprecated. The method will be removed in DDR-Public v2.8.0.")
      document.derivative_ids.map do |id|
          "#{document.derivative_url_prefixes[document.display_format]}#{id}.#{derivative_file_extension(document)}"
      end
    end
  end

  def document_dropdown_label document
    if document.structures.files.count == 1 &&
        document.structures.files.first[:doc].format.present?
      document.structures.files.first[:doc].format.join(' ')
    else
      I18n.t('ddr.public.document_dropdown')
    end
  end


  private

  def facet_search_url(field, value)
    search_action_url(add_facet_params(field, value))
  end

  def derivative_file_extension document
    case document.display_format
    when "audio"
      "mp3"
    when "video"
      "mp4"
    end
  end

  def collections
    @collections ||=
      begin
        response = repository.search(search_builder.where("active_fedora_model_ssi:Collection").merge({fl: "internal_uri_ssi,title_ssi", rows: 9999}))
        response.documents.each_with_object({}) do |doc, memo|
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

  def is_research_guide? value
    research_guides_whitelist.map do |config|
      value =~ /^https?:\/\/#{Regexp.quote(config).chomp('/')}\/.*/
    end.compact.present?
  end

  def research_guides_whitelist
    String(Ddr::Public.research_guides).split(/,\s?/)
  end

end
