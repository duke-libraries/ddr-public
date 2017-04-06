module GoogleAnalyticsHelper

  # Google Analytics Custom Dimensions for Page Views
  # https://developers.google.com/analytics/devguides/collection/analyticsjs/custom-dims-mets

  def ga_permanent_id document, options = {}
    document.permanent_id || document.id
  end

  def ga_document_model document, options = {}
    document.active_fedora_model.downcase
  end

  def ga_admin_set document, options = {}
    document.collection.admin_set || 'none' if document.collection
  end

  def ga_collection document, options = {}
    document.collection.permanent_id || document.collection.id if document.collection
  end

  def ga_item document, options = {}
    document.item.permanent_id || document.item.id if document.item
  end

  private

end
