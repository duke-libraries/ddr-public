module ApplicationHelper
  include Ddr::Public::Controller::SolrQueryConstructor

  # Overrides corresponding method in Blacklight::FacetsHelperBehavior
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    if solr_field == Ddr::Index::Fields::EAD_ID
      # apply custom sort for 'EAD_ID_TITLE' facet
      items = facet_display_value_sort(paginator.items, :ead_id_title)
    else
      items = paginator.items
    end
    safe_join(items.
      map { |item| render_facet_item(solr_field, item) }.compact.
      map { |item| content_tag(wrapping_element,item)}
    )
  end

  def ead_id_title(code)
    Rails.cache.fetch("#{code}/ead_id_title", expires_in: 7.days) do
      begin
        Timeout.timeout(2) do
          Ddr::Models::FindingAid.new(code).collection_title
        end
      rescue OpenURI::HTTPError, Timeout::Error, EOFError => e
        Rails.logger.error { "#{e.message} #{e.backtrace.join("\n")}" }
        code
      end
    end
  end

  # Sort by a method derived title of coded field normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the code
  def facet_display_value_sort(items=[], facet_value_method)
    items.sort { |a,b| send(facet_value_method, a.value).downcase <=> send(facet_value_method, b.value).downcase }
  end

  def alert_messages
    Ddr::Alerts::Message.active.pluck(:message)
  end

  def staff_url(doc_or_obj)
    "#{Ddr::Public.staff_app_url}id/#{doc_or_obj.permanent_id}"
  end

  def url_for_document doc, options = {}
    if respond_to?(:blacklight_config) and
        blacklight_config.show.route
      route = blacklight_config.show.route.merge(action: :show, id: doc).merge(options)
      route[:controller] = controller_name if route[:controller] == :current
      route
    else
      doc
    end
  end

  def git_branch_info
    branch_name = `git rev-parse --abbrev-ref HEAD`
    branch_name
  end

end
