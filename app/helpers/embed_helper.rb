module EmbedHelper

  def embeddable? document
    (['image','folder','audio','video'].include? document.display_format)
  end

  def purl_or_doclink document, options = {}
    @purl_or_doclink ||= (document.permanent_url || "#{ENV['ROOT_URL']}" + document_or_object_url(document))
  end

  def iframe_src_path document, options = {}
    path = purl_or_doclink(document).sub(/^https?:/,'') # make protocol-relative
    path + '?embed=true'
  end

  def iframe_embed_height document, options = {}
    case document.display_format
      when 'audio'
        125
      else
        500
    end
  end

end
