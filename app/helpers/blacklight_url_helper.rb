module BlacklightUrlHelper
  include Blacklight::UrlHelperBehavior

  def url_for_document doc, options = {}
    if doc && doc[Ddr::IndexFields::PERMANENT_URL].present?
      doc[Ddr::IndexFields::PERMANENT_URL]
    else
      super
    end
  end

end
