module BlacklightHelper
  include Blacklight::BlacklightHelperBehavior

  def link_to_document(doc, field_or_opts = nil, opts={:counter => nil})
    field = field_or_opts || document_show_link_field(doc)
    label = presenter(doc).render_document_index_label field, opts
    if can? :read, doc
      link_to label, document_or_object_url(doc), document_link_params(doc, opts)
    else
      content_tag :span, label
    end
  end

  def document_or_object_url(doc_or_obj)
    controllers_and_actions ||= portal_controllers_and_actions()

    document_type = doc_or_obj[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL].downcase.to_sym

    local_id, admin_set = filter_values_for_document(doc_or_obj)

    if controllers_and_actions.has_key?(local_id)
      id = select_document_id(controllers_and_actions[local_id][document_type][0][:action], doc_or_obj)
      url_for controller: controllers_and_actions[local_id][document_type][0][:controller], action: controllers_and_actions[local_id][document_type][0][:action], id: id
    elsif controllers_and_actions.has_key?(admin_set)
      id = select_document_id(controllers_and_actions[admin_set][document_type][0][:action], doc_or_obj)
      url_for controller: controllers_and_actions[admin_set][document_type][0][:controller], action: controllers_and_actions[admin_set][document_type][0][:action], id: id
    else
      url_for controller: controller_name, action: "show", id: doc_or_obj
    end
  end

  def filter_values_for_document(doc_or_obj)
    document_type = doc_or_obj[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL].downcase.to_sym
    local_id = ""
    admin_set = ""
    if document_type == :collection
      local_id = doc_or_obj.local_id if doc_or_obj.local_id
      admin_set = doc_or_obj[Ddr::Index::Fields::ADMIN_SET]
    elsif document_type == :item or document_type == :component
      local_id = local_id_from_uri(doc_or_obj['is_governed_by_ssim'])
      admin_set = admin_set_from_uri(doc_or_obj['is_governed_by_ssim'])
    end
    [local_id, admin_set]
  end

  def select_action_for_collection(controller_type_name)
    if controller_type_name == "collections"
      :index
    else
      :show
    end
  end

  def select_document_id(action, doc_or_obj)
    if action == :index
      nil
    elsif (doc_or_obj.local_id.present? and 
      doc_or_obj[Ddr::Index::Fields::ACTIVE_FEDORA_MODEL] == "Item" and 
      doc_or_obj[Ddr::Index::Fields::ADMIN_SET] == "dc")
        doc_or_obj.local_id
    else
      doc_or_obj
    end
  end

  def portal_controllers_and_actions
    controllers_and_actions = {}
    Rails.application.config.portal_controllers.each do | controller_type_name, controller_type_configs |
      controller_type_configs.each do | portal_name, portal_configs |
        portal_configs['include'].each do | field, ids |
          ids.each do |id|
            unless controllers_and_actions[id]
              controllers_and_actions[id] = {:collection => [], :item => [], :component => []}
              controllers_and_actions[id][:collection] << { :controller => portal_name, :action => select_action_for_collection(controller_type_name) }
              controllers_and_actions[id][:item] << { :controller => portal_name, :action => :show }
              controllers_and_actions[id][:component] << { :controller => portal_name, :action => :show }
            end
          end
        end
      end
    end
    controllers_and_actions
  end

  ##
  # Link to the previous document in the current search context
  # def link_to_previous_document(previous_document)
  #   link_opts = session_tracking_params(previous_document, search_session['counter'].to_i - 1).merge(:class => "previous", :rel => 'prev')
  #   link_to_unless previous_document.nil?, raw(t('views.pagination.previous')), document_or_object_url(previous_document), link_opts do
  #     content_tag :span, raw(t('views.pagination.previous')), :class => 'previous'
  #   end
  # end

  ##
  # Link to the next document in the current search context
  # def link_to_next_document(next_document)
  #   link_opts = session_tracking_params(next_document, search_session['counter'].to_i + 1).merge(:class => "next", :rel => 'next')
  #   link_to_unless next_document.nil?, raw(t('views.pagination.next')), document_or_object_url(next_document), link_opts do
  #     content_tag :span, raw(t('views.pagination.next')), :class => 'next'
  #   end
  # end

end