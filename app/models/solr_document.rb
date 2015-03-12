# -*- encoding : utf-8 -*-
class SolrDocument 

  include Blacklight::Solr::Document
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
    get(Ddr::IndexFields::WORKFLOW_STATE) == "published"
  end

  def inherited_license
    if admin_policy_pid
      query = ActiveFedora::SolrService.construct_query_for_pids([admin_policy_pid])
      results = ActiveFedora::SolrService.query(query)
      doc = results.map { |result| SolrDocument.new(result) }.first
      { title: doc.get(Ddr::IndexFields::DEFAULT_LICENSE_TITLE),
        description: doc.get(Ddr::IndexFields::DEFAULT_LICENSE_DESCRIPTION),
        url: doc.get(Ddr::IndexFields::DEFAULT_LICENSE_URL) }
    end
  end

  def license
    if get(Ddr::IndexFields::LICENSE_TITLE) || get(Ddr::IndexFields::LICENSE_DESCRIPTION) || get(Ddr::IndexFields::LICENSE_URL)
      { title: get(Ddr::IndexFields::LICENSE_TITLE),
        description: get(Ddr::IndexFields::LICENSE_DESCRIPTION),
        url: get(Ddr::IndexFields::LICENSE_URL) }
    end
  end

  def effective_license
    @effective_license ||= license || inherited_license || {}
  end

end
