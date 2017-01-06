class Thumbnail::RepositoryGenerated

  attr_accessor :document


  def initialize(args)
    @document = args.fetch(:document, nil)
  end


  def has_thumbnail?
    repository_generated_thumbnail?
  end

  def thumbnail_path
    if repository_generated_thumbnail?
      Rails.application.routes.url_helpers.thumbnail_path(document.id)
    end
  end

  private

  def repository_generated_thumbnail?
    document.has_thumbnail?
  end

end
