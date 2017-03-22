class Structure

  def initialize(args={})
    @structure = args[:structure]
    @id        = args[:id]
  end

  def default
    @default ||= Structure::Flat.new(structure: @structure, type: 'default')
  end

  def images
    @images ||= Structure::Group.new(structure: @structure, type: 'Images')
  end

  def files
    @files ||= Structure::Group.new(structure: @structure, type: 'Documents')
  end

  def multires_image_file_paths
    if default.docs.any?
      docs = default.docs
    elsif images.docs.any?
      docs = images.docs
    else
      docs = local_id_ordered_components
    end
    @multires_image_file_paths ||= docs.map { |doc| doc.multires_image_file_path }.compact
  end

  def first_multires_image_file_path
    if default.pids.any?
      pids = default.pids
    elsif images.pids.any?
      pids = images.pids
    else
      pids = local_id_ordered_component_pids
    end
    doc = SolrDocument.find(pids.first) if pids.present?
    @first_multires_image_file_path ||= doc.present? ? doc.multires_image_file_path : nil
  end

  def ordered_component_docs
   @ordered_component_docs ||= files.docs
  end

  def derivative_ids
    @derivative_ids ||= default.local_ids.present? ? default.local_ids : local_id_ordered_component_local_ids
  end


  def local_id_ordered_component_pids
    local_id_ordered_components.map { |c| c.id } if local_id_ordered_components
  end

  def local_id_ordered_component_local_ids
    local_id_ordered_components.map { |c| c.local_id }.compact if local_id_ordered_components
  end

  def local_id_ordered_components
    if find_solr_document.components.present?
      find_solr_document.components.sort { |a,b| a.local_id.to_s <=> b.local_id.to_s }
    end
  end

  def find_solr_document
    @solr_document ||= SolrDocument.find(@id)
  end

end