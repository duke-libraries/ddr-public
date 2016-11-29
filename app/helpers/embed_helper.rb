module EmbedHelper

  def embeddable? document
    (['image','multi_image','folder'].include? document.display_format) && (params[:controller] == 'digital_collections')
  end

  def purl_or_doclink document, options = {}
    @purl_or_doclink ||= (document.permanent_url || "#{ENV['ROOT_URL']}" + document_or_object_url(document))
  end

  def iframe_src_path document, options = {}
    path = purl_or_doclink(document).sub(/^https?:/,'') # make protocol-relative
    path + '/embed'
  end

  private


end