module ApplicationHelper

  # Overrides corresponding method in Blacklight::FacetsHelperBehavior
  def render_facet_limit_list(paginator, solr_field, wrapping_element=:li)
    case solr_field
    when Ddr::Index::Fields::ADMIN_SET_FACET
      # apply custom sort for 'admin set' facet
      items = admin_set_facet_sort(paginator.items)
    when Ddr::Index::Fields::COLLECTION_FACET
      # apply custom sort for 'Collection' facet
      items = collection_facet_sort(paginator.items)
    else
      items = paginator.items
    end
    safe_join(items.
      map { |item| render_facet_item(solr_field, item) }.compact.
      map { |item| content_tag(wrapping_element,item)}
    )
  end

  # Custom sort for 'admin set' facet
  # Sort by full name of admin set normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the admin set slug
  # The #admin_set_full_name method is defined in ModelsHelper in ddr-models and is also the view helper for the facet field
  def admin_set_facet_sort(items=[])
    items.sort { |a,b| admin_set_full_name(a.value).downcase <=> admin_set_full_name(b.value).downcase }
  end

  # Custom sort for 'Collection' facet
  # Sort by title of collection normalized to lower case for case-independent sorting
  # The 'value' attribute of each 'item' in the facet is the collection URI
  # The #collection_title method is defined in CatalogHelper and is also the view helper for the facet field
  def collection_facet_sort(items=[])
    items.sort { |a,b| collection_title(a.value).downcase <=> collection_title(b.value).downcase }
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

end
