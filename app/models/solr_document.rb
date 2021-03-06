# -*- encoding : utf-8 -*-
class SolrDocument

  include DocumentModel

  include Blacklight::Solr::Document
  include Blacklight::Gallery::OpenseadragonSolrDocument
  include Ddr::Models::SolrDocument
  include Rails.application.routes.url_helpers # enable url_for method to get stream_url

  extend Forwardable

  def_delegators :structures,
                 :derivative_ids,
                 :multires_image_file_paths,
                 :first_multires_image_file_path,
                 :media_paths,
                 :first_media_doc,
                 :captions_urls,
                 :captions_paths,
                 :ordered_component_docs

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

  def controller_scope
    ApplicationController.try(:current)
  end

  def published?
    self[Ddr::Index::Fields::WORKFLOW_STATE] == "published"
  end

  def abstract
    Array(self[ActiveFedora::SolrService.solr_name(:abstract, :stored_searchable)]).first
  end

  def description
    Array(self[ActiveFedora::SolrService.solr_name(:description, :stored_searchable)]).first
  end

  def rights_notes
    Array(self[ActiveFedora::SolrService.solr_name(:rights_note, :stored_searchable)])
  end

  def format
    Array(self[ActiveFedora::SolrService.solr_name(:format, :stored_searchable)])
  end

  def sponsor
    Array(self[ActiveFedora::SolrService.solr_name(:sponsor, :stored_searchable)]).first
  end

  def sponsor_display
    sponsor_display ||= self.sponsor ||
                        self.parent.sponsor ||
                        self.collection.sponsor ||
                        I18n.t('ddr.public.call_to_sponsor', default: 'Sponsor this Digital Collection')
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

  def stream_url
    if self.streamable?
      url_for(id: self.id, controller: "stream", action: "show", only_path: true)
    end
  end

  def captions_url
    if self.captionable?
      url_for(id: self.id, controller: "captions", action: "show", only_path: true)
    end
  end

  def related_items
    item_relator_config ? item_relator_config.map { |config| RelatedItem.new({document: self, config: config}) } : []
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

  def structures
    @structures ||= Structure.new(structure: self.structure, id: self.id)
  end


  private

  Restrictions = Struct.new(:max_download)

  def item_relator_config
    portal_view_config.try(:[], 'item_relators')
  end

  def max_download
    portal_view_config.try(:[], 'restrictions').try(:[], 'max_download')
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
