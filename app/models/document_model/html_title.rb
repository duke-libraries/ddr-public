module DocumentModel::HtmlTitle

  def html_title_qualifier title, qualifier

    # Google SEO recommends that titles be short, unique, and avoid vague terms like Untitled.
    # Since generic titles happen frequently among DDR content, we'll append an ID to the title in those cases.
    # https://is.gd/wbpLAf

    append_qualifier = ''
    generic_titles = [  'unknown','[unknown]',
                        'no known title','[no known title]',
                        'unknown title','[unknown title]',
                        'title unknown','[title unknown]',
                        'untitled','[untitled]',
                        'n/a','[n/a]' ]

    if generic_titles.include? title.downcase
      append_qualifier = " (#{qualifier})"
    end
    append_qualifier
  end

end
