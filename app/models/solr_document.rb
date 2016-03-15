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
    get("abstract_tesim")
  end

  def description
    get("description_tesim")
  end

  def public_controller
    public_controller = effective_configs.try(:[] , 'controller')
    public_controller ||= 'catalog'
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
  

  private

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
