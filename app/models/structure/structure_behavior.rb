module Structure::StructureBehavior

  attr_accessor :structure, :type

  def initialize(args={})
    @structure = args[:structure]
    @type      = args[:type]
    super(docs_list)
  end

  def docs_list
    docs.zip(labels, order).map { |h| Hash[doc: h[0], label: h[1], order: h[2]] }
  end

  def docs
    ordered_documents(pids) if pids.present? || []
  end

  def local_ids
    docs.map { |doc| doc.local_id } if pids.present? || []
  end


  private

  def find_multires_image_file_paths
    if docs.present?
      docs.map { |doc| doc.multires_image_file_path }.compact
    else
      nil
    end
  end

  def find_first_multires_image_file_path
    if pids.present?
      SolrDocument.find(pids.first).multires_image_file_path
    else
      nil
    end
  end

  def ordered_documents(pids)
    solr_documents = response_to_solr_docs(pids)
    pids.map{ |pid| solr_documents.find{ |doc| doc["id"] == pid } }
  end

  def response_to_solr_docs(pids)
    merged_response_docs(pids).map { |doc| SolrDocument.new(doc) }
  end

  def merged_response_docs(pids)
    pids_searches(pids).map { |response| response['response']['docs']}.flatten
  end

  def pids_searches(pids)
    pids_queries(pids).map { |query| pids_search(query) }
  end

  def pids_queries(pids)
    sliced_pids(pids).map { |pids| pids_query(pids) }
  end

  # NOTE: Dividing long array of pids into multiple arrays of 100
  #       pids each so as not to exceed request size limits.
  def sliced_pids(pids)
    pids.each_slice(100).to_a
  end

  def pids_search(query)
    ActiveFedora::SolrService.instance.conn.post('select', :params=> {:q=>query,
                                                                      :qt=>'standard',
                                                                      :rows=>100} )
  end

  def pids_query(pids)
    ActiveFedora::SolrService.construct_query_for_pids(pids)
  end

  def group_content(type='default')
    root_content.select { |c| c['type'] == type }.map { |t| t['contents'] }.flatten
  end

  def root_content(type='default')
    type_root_node(type).present? ? type_root_node(type)['contents'] : {}
  end

  def type_root_node(type='default')
    @structure ? @structure[type] : {}
  end

end