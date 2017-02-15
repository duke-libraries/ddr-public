# -*- encoding : utf-8 -*-
class SolrDocument

  include DocumentModel

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument

  include Ddr::Models::SolrDocument

  # self.unique_key = 'id'

  # Email uses the semantic field mappings below to generate the body of an email.
  SolrDocument.use_extension( Blacklight::Document::Email )

  # SMS uses the semantic field mappings below to generate the body of an SMS email.
  SolrDocument.use_extension( Blacklight::Document::Sms )

  # DublinCore uses the semantic field mappings below to assemble an OAI-compliant Dublin Core document
  # Semantic mappings of solr stored fields. Fields may be multi or
  # single valued. See Blacklight::Solr::Document::ExtendableClassMethods#field_semantics
  # and Blacklight::Solr::Document#to_semantic_values
  # Recommendation: Use field names from Dublin Core
  use_extension( Blacklight::Document::DublinCore)

  def sponsor_display
    sponsor_display ||= self['sponsor_tesim'] ||
                        self.parent['sponsor_tesim'] ||
                        self.collection['sponsor_tesim'] ||
                        I18n.t('ddr.public.call_to_sponsor', default: 'Sponsor this collection.')
  end

  def controller_scope
    ApplicationController.try(:current)
  end

  def published?
    self[Ddr::Index::Fields::WORKFLOW_STATE] == "published"
  end

  def abstract
    Array(self["abstract_tesim"]).first
  end

  def description
    Array(self["description_tesim"]).first
  end

  def relation
    Array(self["relation_tesim"])
  end

  def thumbnail
    portal_doc_config.try(:[], 'collection_local_id').try(:[], self.local_id).try(:[], 'thumbnail_image')
  end

  def derivative_url_prefixes
    portal_view_config.try(:[], 'derivative_url_prefixes')
  end

  def item_relators
    portal_view_config.try(:[], 'item_relators')
  end

  def restrictions
    Restrictions.new(max_download)
  end

  def public_controller
    public_controller = effective_configs.try(:[] , 'controller')
    public_controller ||= 'catalog'
  end

  def public_collection
    effective_configs.try(:[] , 'collection')
  end

  def public_action
    if dc_collection? && self.local_id
      "index"
    else
      "show"
    end
  end

  def public_id
    if dc_collection?
      nil
    elsif dc_item?
      self.local_id ? self.local_id : self.id
    else
      self.id
    end
  end


  # This assumes that the derivative IDs are the local_ids of an item's components
  def derivative_ids(type='default')
    ordered_component_docs(type).map { |doc| doc.local_id }.compact
  end

  def multires_image_file_paths
    @multires_image_file_paths ||= find_multires_image_file_paths
  end

  def first_multires_image_file_path
    @first_multires_image_file_path ||= find_first_multires_image_file_path
  end


  def ordered_component_pids(type='default')
    [struct_map_ordered_pids(type), local_id_order_component_pids].find { |val| val.present? }
  end

  def ordered_component_docs(type='default')
    [struct_map_ordered_docs(type), local_id_order_component_docs].find { |val| val.present? }
  end

  private

  Restrictions = Struct.new(:max_download)

  def max_download
    portal_view_config.try(:[], 'restrictions').try(:[], 'max_download')
  end

  def find_multires_image_file_paths
    docs = ordered_component_docs('Images')
    if docs.present?
      docs.map { |doc| doc.multires_image_file_path }.compact
    else
      nil
    end
  end

  def find_first_multires_image_file_path
    pids = ordered_component_pids('Images')
    if pids.present?
      self.class.find(pids.first).multires_image_file_path
    else
      nil
    end
  end

  def struct_map_ordered_docs(type='default')
    pids = struct_map_ordered_pids(type)
    ordered_documents(pids) if pids.present?
  end

  def struct_map_ordered_pids(type='default')
    if struct_map.present?
      fptrs.any? ? fptrs : nested_fprts(type)
    end
  end

  def nested_fprts(type='default')
    type_div = struct_map['divs'].select { |div| div['type'] == type }.first || {}
    if type_div.any?
      type_div['divs'].map { |div| div['fptrs'] }.flatten.compact
    end
  end

  def fptrs
    struct_map['divs'].map { |div| div['fptrs'] }.flatten.compact
  end

  def local_id_order_component_pids
    local_id_order_component_docs.map(&:id) if components.present?
  end

  def local_id_order_component_docs
    components.sort { |a,b| a.local_id <=> b.local_id } if components.present?
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
    ActiveFedora::SolrService.instance.conn.post('select', :params=> {:q=>query, :qt=>'standard' , :rows=>100} )
  end

  def pids_query(pids)
    ActiveFedora::SolrService.construct_query_for_pids(pids)
  end

  def effective_configs
    [collection_pid_configuration, dc_generic_configuration, collection_pid_configuration].compact.first
  end

  def admin_set_configuration
    portal_doc_config.try(:[], 'admin_sets').try(:[], admin_policy_admin_set)
  end

  def collection_pid_configuration
    portal_doc_config.try(:[], 'portals').try(:[], 'collection_local_id').try(:[], admin_policy_local_id)
  end

  def dc_generic_configuration
    if admin_policy_local_id && admin_policy_admin_set == 'dc'
      {"controller"=>"digital_collections", "collection"=>admin_policy_local_id, "item_id_field"=>"local_id"}
    end
  end

  def dc_collection?
    admin_policy_admin_set == 'dc' && self.active_fedora_model == 'Collection'
  end

  def dc_item?
    admin_policy_admin_set == 'dc' && self.active_fedora_model == 'Item'
  end

  def portal_doc_config
    Rails.application.config.portal.try(:[], 'portals')
  end

  def portal_view_config
    Rails.application.config.portal.try(:[], 'controllers').try(:[], admin_policy_local_id)
  end

  def admin_policy_admin_set
    Rails.cache.fetch("admin_policy_admin_set/#{self.admin_policy_id}", expires_in: 7.days) do
      self.admin_policy.admin_set
    end
  end

  def admin_policy_local_id
    Rails.cache.fetch("admin_policy_local_id/#{self.admin_policy_id}", expires_in: 7.days) do
      self.admin_policy.local_id
    end
  end

end
