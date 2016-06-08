module MultiresImageHelper

  include Ddr::Public::Controller::IiifImagePaths

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


  def multi_image_sorted_derivative_paths(ptifs, options)
    # For an item page with multi-res image(s), get an array of absolute URLs to JPG
    # derivatives for each page, sorted by struct_map order. Accept image server
    # options to customize sizes, especially for download.

    derivs ||= []

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

  def image_item_tilesources(paths)
    sources ||= []
    paths.each { |item|
      sources.push(iiif_image_info_path(item))
    }
    sources
  end

  def image_item_aspectratio(paths)
    # Get the width / height ratio of the first multires component's image
    urls = image_item_tilesources(paths)

    # Circumvent https error despite valid SSL cert
    imagedata ||= JSON.load(open(urls.first, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }))

    aspectratio ||= (imagedata['width'].to_f/imagedata['height'].to_f)
  end

  def image_component_tilesource(document)
    # For a single component object that has a multi-res image, get the info.json path.
    source ||= iiif_image_info_path(document.multires_image_file_path)
  end

  def image_component_aspectratio(document)
  # Get the width / height ratio of the multi-res component's image
    url = iiif_image_info_path(document.multires_image_file_path)
    imagedata ||= JSON.load(open(url, { ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE }))
    aspectratio ||= (imagedata['width'].to_f/imagedata['height'].to_f)
  end

end
