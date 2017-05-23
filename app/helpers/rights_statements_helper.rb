module RightsStatementsHelper

  def rights_display options={}
    document = options[:document]

    begin
      if document.rights_statement.present?
        rights = []
        rights << rights_reuse_text(document.rights_statement)
        rights << rights_link(document.rights_statement)
        rights.join.html_safe
      end
    rescue => e
      Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
      link_to(document.rights[0], document.rights[0])
    end

  end

  private

  def rights_reuse_text rights_statement
    if rights_statement.reuse_text.present?
      content_tag(:span, rights_statement.reuse_text, class: "rights-reuse-text")
    end
  end

  def rights_link rights_statement
    link_to(rights_statement.url, rel: "license", target: "_blank") do
      link = []
      link << rights_icons(rights_statement)
      link << rights_statement.short_title
      link.join.html_safe
    end
  end

  def rights_icons rights_statement
    if rights_statement.feature.present?
      icons = rights_statement.feature.map { |feature| rights_icon(feature) }
    end
  end

  def rights_icon feature
    content_tag(:span, "", class: ["icon-rights","icon-rights-"+feature])
  end

end
