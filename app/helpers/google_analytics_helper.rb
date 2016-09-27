module GoogleAnalyticsHelper

  # Google Analytics Custom Dimensions for Page Views
  # https://developers.google.com/analytics/devguides/collection/analyticsjs/custom-dims-mets

  def ga_permanent_id document, options = {}
    @ga_permanent_id ||= (document.permanent_id || document.id)
  end

  def ga_document_model document, options = {}
    @ga_document_model ||= document.active_fedora_model.downcase
  end

  def ga_admin_set document, options = {}
    @ga_admin_set ||= (document.collection.admin_set || 'none')
  end

  def ga_collection document, options = {}
    @ga_collection ||= (document.collection.permanent_id || document.collection.id)
  end

  def ga_item document, options = {}
    @ga_item ||= (document.item.permanent_id || document.item.id)
  end

  private

end
