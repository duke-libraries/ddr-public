class RelatedItem

  extend Forwardable

  def_delegators :@related_item,
                 :name,
                 :related_documents,
                 :related_documents_count,
                 :solr_query

  def initialize args={}
    @document     = args[:document]
    @config       = args[:config]
    @related_item = related_item_class.new({ document: @document, config: @config })
  end


  private

  def related_item_class
    if @config.has_key?('id_field')
      RelatedItem::IdReference
    else
      RelatedItem::SharedValue
    end
  end

end
