module DocumentModel

  def collection
    document_model.try(:collection)
  end

  def item
    document_model.try(:item)
  end

  def items
    document_model.try(:items)
  end

  def item_count
    document_model.try(:item_count)
  end

  def components
    document_model.try(:components)
  end

  def component_count
    document_model.try(:component_count)
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
