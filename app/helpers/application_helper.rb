module ApplicationHelper

  # Overrides corresponding method in Blacklight::FacetsHelperBehavior
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    case solr_field
    when Ddr::Index::Fields::ADMIN_SET_FACET
      # apply custom sort for 'admin set' facet
      items = admin_set_facet_sort(paginator.items)
    when Ddr::Index::Fields::COLLECTION_FACET
      # apply custom sort for 'Collection' facet
      items = collection_facet_sort(paginator.items)
    else
      items = paginator.items
    end
    safe_join(items.
      map { |item| render_facet_item(solr_field, item) }.compact.
      map { |item| content_tag(wrapping_element,item)}
    )
  end

  # Custom sort for 'admin set' facet
  # Sort by full name of admin set normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the admin set slug
  # The #admin_set_full_name method is defined in ModelsHelper in ddr-models and is also the view helper for the facet field
  def admin_set_facet_sort(items=[])
    items.sort { |a,b| admin_set_full_name(a.value).downcase <=> admin_set_full_name(b.value).downcase }
  end

  # Custom sort for 'Collection' facet
  # Sort by title of collection normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the collection URI
  # The #collection_title method is defined in CatalogHelper and is also the view helper for the facet field
  def collection_facet_sort(items=[])
    items.sort { |a,b| collection_title(a.value).downcase <=> collection_title(b.value).downcase }
  end

  def alert_messages
    Ddr::Alerts::Message.active.pluck(:message)
  end

  def thumbnail_image_tag document, image_options = {}
    src = document.has_thumbnail? && can?(:read, document) ? thumbnail_path(document) : default_thumbnail(document)
    thumbnail = image_tag(src, :alt => "Thumbnail", :class => "img-thumbnail", size: "100x100")
  end

  def default_thumbnail(doc_or_obj)
    if doc_or_obj.has_content?
      default_mime_type_thumbnail(doc_or_obj.content_type)
    else
      default_model_thumbnail(doc_or_obj.active_fedora_model)
    end
  end

  def default_mime_type_thumbnail(mime_type)
    case mime_type
    when /^image/
      'crystal-clear/image2.png'
    when /^video/
      'crystal-clear/video.png'
    when /^audio/
      'crystal-clear/sound.png'
    when /^application\/(x-)?pdf/
      'crystal-clear/document.png'
    when /^application/
      'crystal-clear/binary.png'
    else
      'crystal-clear/misc.png'
    end
  end

  def default_model_thumbnail(model)
    case model
    when 'Collection'
      'crystal-clear/kmultiple.png'
    else
      'crystal-clear/misc.png'
    end
  end

  def staff_url(doc_or_obj)
    "#{Ddr::Public.staff_app_url}id/#{doc_or_obj.permanent_id}"
  end

  # Build IIIF image tags for image files served by IIP Image Server

  def iiif_image_path(filepath,options)
    size = options[:size] ? options[:size] : 'full'
    region = options[:region] ? options[:region] : 'full'
    url = "#{Ddr::Models.image_server_url}?IIIF=#{filepath}/#{region}/#{size}/0/default.jpg"
  end
  
  def iiif_image_info_path(filepath)
    url = "#{Ddr::Models.image_server_url}?IIIF=#{filepath}/info.json"    
  end

  def iiif_image_tag(filepath,options)
    url = iiif_image_path(filepath,options)
    image_tag url, :alt => options[:alt].presence, :class => options[:class].presence
  end
  
  
  
  # STRUCTURAL METADATA HELPERS
  # ===========================
  
  # Get an array of component pids for any item, sorted by the 
  # order indicated in the default struct_map. This is complicated
  # with nesting possible; we have to deal with arrays of hashes
  # with arrays for values, etc... 

  def sorted_pids(document)
    
    if document.struct_map
      
      # Sort the divs in the structmap by the ORDER attribute.
      pids = document.struct_map["divs"].sort_by { |h| h["order"].to_i }
    
      # Make an array of pids from the structmap div fptr. Assumes only one fptr per div.
      sorted_pids = pids.map { |item| item["fptrs"].first }
      
    end

  end

  def multi_image_sorted_paths(document, doclist)
    # For an item page with multi-res image(s), get an array of image component multires image URLs.
    # Iterate over an array of component pids sorted by struct_map order. Retrieve each's respective 
    # ptif path. Create a new array with those paths.
    
    components = doclist.map { |doc| { file: doc.multires_image_file_path, id: doc.id } }
    paths = []
    
    if document.struct_map
      sorted_pids(document).each { |item|
        c = components.detect { |h| h[:id] == item } 
        paths.push((c[:file]))     
      }
    else
      # If no struct_map present, render components in native order
      components.each { |item|
        paths.push(item[:file])
      }
    end

    paths    
  end

  def multi_image_sorted_derivative_paths(document, doclist, options)
    # For an item page with multi-res image(s), get an array of absolute URLs to JPG 
    # derivatives for each page, sorted by struct_map order. Accept image server 
    # options to customize sizes, especially for download.
    
    ptifs = multi_image_sorted_paths(document, doclist)  
    derivs = []
  
    ptifs.each { |image| 
      d = iiif_image_path(image,options)
      derivs.push(d)
    }
    
    derivs  
     
  end
  
  # This helper is used for the multi-image ZIP downloading feature. 
  # TO-DO: find a better way to do this.
  def array_to_delimited_str(array)
    s = ""
    array.each { |item|
      s << item+"||"
    }
    s
  end

  def image_item_tilesources(document, doclist)
    paths = multi_image_sorted_paths(document, doclist)
    sources = []
    paths.each { |item|
      sources.push(iiif_image_info_path(item))
    }
    sources
  end
  
  def image_item_aspectratio(document, doclist)
    # Get the width / height ratio of the first multires component's image
    urls = image_item_tilesources(document, doclist)
    
    # Circumvent https error despite valid SSL cert
    imagedata = JSON.load(open(urls.first, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }))
    
    aspectratio = (imagedata['width'].to_f/imagedata['height'].to_f)    
  end
  
  def image_component_tilesource(document)
    # For a single component object that has a multi-res image, get the info.json path.   
    source = iiif_image_info_path(document.multires_image_file_path)
  end  
 
  def image_component_aspectratio(document)
  # Get the width / height ratio of the multi-res component's image  
    url = iiif_image_info_path(document.multires_image_file_path)
    imagedata = JSON.load(open(url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }))
    aspectratio = (imagedata['width'].to_f/imagedata['height'].to_f)    
  end

  def url_for_document doc, options = {}
    if respond_to?(:blacklight_config) and
        blacklight_config.show.route
      route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
      route[:controller] = controller_name if route[:controller] == :current
      route
    else
      doc
    end
  end

end
