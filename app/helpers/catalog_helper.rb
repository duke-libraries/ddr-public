module CatalogHelper
  include Blacklight::CatalogHelperBehavior

  def collection_title value
    Collection.find(value.split('/').last).title_display
  end
end