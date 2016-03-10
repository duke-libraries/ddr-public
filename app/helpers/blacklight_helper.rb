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
    if doc_or_obj.public_collection.present?
      url_for controller: doc_or_obj.public_controller, action: doc_or_obj.public_action, collection: doc_or_obj.public_collection, id: doc_or_obj.public_id, only_path: true
    else
      url_for controller: doc_or_obj.public_controller, action: doc_or_obj.public_action, id: doc_or_obj.public_id, only_path: true
    end
  end

end
