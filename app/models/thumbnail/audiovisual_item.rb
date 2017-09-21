class Thumbnail::AudiovisualItem

  attr_accessor :document

  def initialize(args)
    @document = args.fetch(:document, nil)
  end

  def has_thumbnail?
    document.display_format =~ /audio|video/ && repository_generated_thumbnail? ? true : false
  end

  def thumbnail_path
    if has_thumbnail?
      Rails.application.routes.url_helpers.thumbnail_path(first_media_doc_id)
    end
  end

  private

  def repository_generated_thumbnail?
    document.first_media_doc.has_thumbnail?
  end

  def first_media_doc_id
    document.first_media_doc.id
  end

end
