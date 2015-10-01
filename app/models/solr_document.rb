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

  # Stub value for format and collection that drive partial selection
  # for item display. Eventually these values will be in each Solr Document.
  # def initialize(source_doc={}, response=nil)
  #     super
  #     unless source_doc.has_key?('format')
  #       source_doc['format'] = 'image'
  #     end
  #     unless source_doc.has_key?('collection')
  #       source_doc['collection'] = 'blake'
  #     end     
  # end



end
