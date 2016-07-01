module DocumentModel

  def collection
    @collection ||= document_model.try(:collection)
  end

  def item
    @item ||= document_model.try(:item)
  end

  def items
    @items ||= document_model.try(:items)
  end

  def item_count
    @item_count ||= document_model.try(:item_count)
  end

  def components
    @components ||= document_model.try(:components)
  end

  def component_count
    @component_count ||= document_model.try(:component_count)
  end

  def display_format_icon
    case self.display_format
    when 'multi_image'
      'clone'
    when 'folder'
      'folder-open-o'
    when 'video'
      'film'
    when 'audio'
      'headphones'
    else
      'file-o'
    end
  end

  def metadata_header
    document_model.try(:metadata_header) || "Item Info"
  end

  private

  def document_model
    document_model_class.new({ document: self })
  end

  def document_model_class
    "DocumentModel::#{current_document_model}".safe_constantize
  end

  def current_document_model
    document_models.select { |model| model == self.active_fedora_model }.first
  end

  def document_models
    ["Collection", "Item", "Component"]
  end

end
