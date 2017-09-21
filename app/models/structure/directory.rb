class Structure::Directory < SimpleDelegator

  attr_accessor :structure

  def initialize(args={})
    @structure = args[:structure]
    super(root_directory)
  end

  def item_pid_lookup
    @item_pid_lookup ||= generate_item_pid_lookup_hash(root_directory)
  end

  def directory_id_lookup
    @directory_id_lookup ||= generate_directory_id_lookup(root_directory)
  end

  private

  def generate_item_pid_lookup_hash(contents, collector={}, directories=[])
    return if contents.nil?

    contents.each do |content|
      if is_directory?(content)
        generate_item_pid_lookup_hash(content["contents"], collector, directories.dup << content["label"])
      else
        collector[file_pid(content)] = { files: select_files(contents), parent_directories: directories }
      end
    end

    collector
  end

  def generate_directory_id_lookup(contents, collector={}, parent="root", count=0)

    return if contents.nil?
    collector[parent] = [] unless collector.has_key? parent

    contents.each do |content|
      count = count + 1
      if is_directory?(content)
        opened_state = count == 1 ? true : false
        id = generate_id(content, count)
        collector[parent] << { text:     content["label"],
                               id:       id,
                               icon:     'fa fa-folder',
                               children: true,
                               a_attr: { href: 'javascript:void(0);' },
                               state:    { opened: opened_state } }
        generate_directory_id_lookup(content["contents"], collector, id, count)
      else
        collector[parent] << { repo_id: file_pid(content) }
      end
    end
    collector
  end

  def generate_id(content, count)
    Digest::SHA1.hexdigest("#{content}#{count}")
  end

  def select_files(contents)
    contents.select { |sib| sib["contents"].first.has_key?("repo_id") }.map { |doc_sib| file_pid(doc_sib) }
  end

  def file_pid(doc_content)
    doc_content["contents"].first["repo_id"]
  end

  def is_directory?(content)
    content.respond_to?(:has_key?) && content.has_key?("type") && content["type"] == "Directory"
  end

  def root_directory
    if structure && structure["default"] && structure["default"]["contents"]
      structure["default"]["contents"].select { |content| content["type"] == "Directory" }
    else
      []
    end
  end

end
