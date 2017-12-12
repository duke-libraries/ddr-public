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

  def media
    @media ||= Structure::Group.new(structure: @structure, type: 'Media')
  end

  def directories
    @directories ||= Structure::Directory.new(structure: @structure)
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
    docs = []
    pids[0..9].each do |pid|
      doc = SolrDocument.find(pid)
      docs << doc
      break if doc[Ddr::Index::Fields::WORKFLOW_STATE] == 'published'
    end
    @first_multires_image_file_path ||= docs.last.present? ? docs.last.multires_image_file_path : nil
  end

  def media_paths
    if default.docs.any?
      docs = default.docs
    elsif media.docs.any?
      docs = media.docs
    else
      docs = local_id_ordered_components
    end
    @media_paths ||= docs.map { |doc| doc.stream_url }.compact
  end

  def first_media_doc
    if default.pids.any?
      pids = default.pids
    elsif media.pids.any?
      pids = media.pids
    else
      pids = local_id_ordered_component_pids
    end
    @first_media_doc ||= SolrDocument.find(pids.first) if pids.present?
  end

  def captions_urls
    if default.docs.any?
      docs = default.docs
    elsif media.docs.any?
      docs = media.docs
    elsif local_id_ordered_components.present?
      docs = local_id_ordered_components
    else
      docs = [] << find_solr_document # for a component
    end
    @captions_urls ||= docs.map { |doc| doc.captions_url }.compact
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
    else
      []
    end
  end

  def find_solr_document
    @solr_document ||= SolrDocument.find(@id)
  end

end
