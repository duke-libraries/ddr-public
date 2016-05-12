# -*- encoding : utf-8 -*-
class SolrDocument

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  include Ddr::Models::SolrDocument

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Solr::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Solr::Document::DublinCore)

  def published?
    get(Ddr::Index::Fields::WORKFLOW_STATE) == "published"
  end

  def abstract
    get(ActiveFedora::SolrService.solr_name(:abstract, :stored_searchable))
  end

  def description
    get(ActiveFedora::SolrService.solr_name(:description, :stored_searchable))
  end

  def public_controller
    public_controller = effective_configs.try(:[] , 'controller')
    public_controller ||= 'catalog'
  end

  def thumbnail
    Rails.application.config.portal['portals']['collection_local_id'].try(:[], self.local_id).try(:[], 'thumbnail_image')
  end

  def public_collection
    effective_configs.try(:[] , 'collection')
  end

  def public_action
    if Rails.application.config.portal['portals']['collection_local_id'][self.local_id]
      "index"
    else
      "show"
    end
  end

  def public_id
    if self.parent && collection_pid_configuration.try(:[], 'item_id_field') == 'local_id' && self.active_fedora_model != "Component"
      public_id = self.local_id ? self.local_id : self.id
    else
      public_id = self.id unless Rails.application.config.portal.try(:[], 'portals').try(:[], 'collection_local_id').try(:[], self.local_id)
    end
  end

  # This assumes that the derivative IDs are the local_ids of an item's components
  def derivative_ids(type='default')
    struct_map_docs(type).map { |doc| doc.local_id }.compact
  end


  # Support for Struct Maps with nested divs
  # TODO: integrate nested div structure into ddr-models struct_map methods

  def multires_image_file_paths(type='default')
    nested_docs = nested_struct_map_docs('Images')
    docs = nested_docs.any? ? nested_docs : struct_map_docs(type)
    docs.map { |doc| doc.multires_image_file_path }.compact
  end

  def first_multires_image_file_path(type='default')
    nested_pids = nested_struct_map_pids('Images')
    pids = nested_pids.any? ? nested_pids : struct_map_pids(type)
    unless pids.blank?
      paths = self.class.find(pids.first).multires_image_file_path
    else
      nil
    end
  end

  def struct_map_docs(type='default')
    pids = struct_map_pids(type)
    ordered_documents(pids)
  end

  def nested_struct_map_docs(type='default')
    pids = nested_struct_map_pids(type)
    ordered_documents(pids)
  end

  def nested_struct_map_pids(type='default')
    nested_struct_map(type).map { |d| d['divs'].map { |d| d['fptrs'].first } }.flatten.compact
  rescue
    []
  end

  def nested_struct_map(type='default')
    struct_map.present? ? struct_map['divs'].select { |d| d['type'] == type }.compact : nil
  end


  private

  def ordered_documents(pids)
    pids.map{ |pid| response_to_solr_docs(pids).find{ |doc| doc["id"] == pid } }
  end

  def response_to_solr_docs(pids)
    @response_to_solr_docs ||= merged_response_docs(pids).map { |doc| SolrDocument.new(doc) }
  end

  def merged_response_docs(pids)
    @merged_response_docs ||= pids_searches(pids).map { |response| response['response']['docs']}.flatten
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
    ActiveFedora::SolrService.instance.conn.post('select', :params=> {:q=>query, :qt=>'standard' , :rows=>100} )
  end

  def pids_query(pids)
    ActiveFedora::SolrService.construct_query_for_pids(pids)
  end



  def effective_configs
    applied_configs = collection_pid_configuration()
    applied_configs ||= admin_set_configuration()
  end

  def admin_set_configuration
    admin_set = SolrDocument.find(self.admin_policy_pid).admin_set
    Rails.application.config.portal.try(:[], 'portals').try(:[], 'admin_sets').try(:[], admin_set)
  end

  def collection_pid_configuration
    local_id = SolrDocument.find(self.admin_policy_pid).local_id
    Rails.application.config.portal.try(:[], 'portals').try(:[], 'collection_local_id').try(:[], local_id)
  end




end
