module MultiresImageHelper

  include Ddr::Public::Controller::IiifImagePaths

  def iiif_image_tag(filepath,options)
    url = iiif_image_path(filepath,options)
    image_tag url, :alt => options[:alt].presence, :class => options[:class].presence
  end


  def multi_image_derivatives ptifs, options={}
    # For an item page with multi-res image(s), get an array of absolute URLs to JPG
    # derivatives for each page. Accept image server
    # options to customize sizes, especially for download.

    derivs ||= []

    ptifs.each { |image|
      d = iiif_image_path(image,options)
      derivs.push(d)
    }

    derivs

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

  # Download Menu Helpers for Multi-Image Items
  def multi_image_download_button document, options = {}
    button_to options[:label],
    {
      controller: "catalog",
      action: options[:action]
    },
    {
      method: :post,
      params: {
        image_list: multi_image_derivatives(@document.multires_image_file_paths, { :size => multi_image_max_download_size(@document) }).join('||'),
        itemid: @document.local_id
      },
      class: "btn btn-link"
    }
  end

  def image_download_link document, options = {}
    link_to (options[:linklabel] + ' ' + content_tag(:span, multi_image_download_label(options[:pixels]), :class => "text-muted img-size")).html_safe, iiif_image_path(options[:path], {:size => iiif_image_size_maxpx(options[:pixels])}), class: "download-link-single", download: ""
  end

  private


  def multi_image_max_download_size document, options = {}
    document.restrictions.max_download.present? ? iiif_image_size_maxpx(document.restrictions.max_download.to_s) : 'full'
  end

  def multi_image_download_label pixels
    px = pixels.to_s || ''
    px.present? ? number_with_delimiter(px) + 'px' : 'Original Resolution'
  end
 
end
