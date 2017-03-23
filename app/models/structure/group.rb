class Structure::Group < SimpleDelegator

  include Structure::StructureBehavior


  def pids
    type_group_content('contents').flatten.map { |component| component['repo_id'] }
  end

  def labels
    type_group_content('label')
  end

  def order
    type_group_content('order')
  end

  def label
    attribute_value('label')
  end

  def id
    attribute_value('id')
  end


  private

  def type_group_content(attribute)
    group_content(@type).map { |content| content[attribute] }
  end

  def attribute_value(attribute)
    root_content.select { |node| node['type'] == @type }.first[attribute]
  end

end
