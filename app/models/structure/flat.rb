class Structure::Flat < SimpleDelegator

  include Structure::StructureBehavior


  def pids
    order_attribute_value('contents').flatten.map { |component| component['repo_id'] }.compact
  end

  def labels
    order_attribute_value('label')
  end

  def order
    order_attribute_value('order')
  end

  def label
    root_attribute_value('label')
  end


  private

  def order_attribute_value(attribute)
    root_content(@type).map { |content| content[attribute] }
  end

  def root_attribute_value(attribute)
    type_root_node(type)[attribute]
  end

end
