module HtmlTitleHelper
  include Blacklight::CatalogHelperBehavior

  def search_results_html_title portal
    t('blacklight.search.page_title.title',
      :constraints => ([render_search_to_page_title(params), portal.html_title_context].join(' / ')),
      :application_name => application_name)   
  end

  # See existing "render_search_to_page_title" Blacklight method, which doesn't work
  # well for blank (no keywords or facet selections) searches:
  # https://is.gd/TQ6Diz

  # Rather than duplicate that method here, the alias_method_chain lets us
  # intercept calls to that method, prepend a conditional, then in some
  # conditions (non-blank searches), call the method as originally defined.
  # https://apidock.com/rails/Module/alias_method_chain

  def render_search_to_page_title_with_blank_catch(params)
    if render_search_to_page_title_without_blank_catch(params).present?
      render_search_to_page_title_without_blank_catch(params)
    else
      'Browse Everything'
    end
  end

  alias_method_chain :render_search_to_page_title, :blank_catch

end
