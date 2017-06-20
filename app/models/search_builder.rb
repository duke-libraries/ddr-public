class SearchBuilder < Blacklight::Solr::SearchBuilder

  def include_only_published(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Ddr::Index::Fields::WORKFLOW_STATE}:published"
  end

  def include_only_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Collection"
  end

  def include_only_items(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item"
  end

  def exclude_components(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << "-#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Component"
  end

  def filter_by_parent_collections(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << portal_filters
    solr_parameters[:portal_q] = [portal_q]
    solr_parameters
  end

  def apply_access_controls(solr_parameters)
    solr_parameters[:fq] ||= []
    solr_parameters[:fq] << gated_discovery_filters.join(" OR ")
    solr_parameters[:policy_q] = [policy_q]
    solr_parameters[:resource_q] = [resource_q]
    solr_parameters
  end

  def filter_by_related_items(solr_parameters)
    if blacklight_params[:id_related_items].present?
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << related_item_filters
      solr_parameters[:related_items_q] = [related_items_q]
      solr_parameters
    end
  end


  private

  def policy_q
    if policy_role_policies.present?
      join_query_values(policy_role_policies)
    end
  end

  def resource_q
    join_query_values(current_ability.agents)
  end

  def portal_q
    join_query_values(scope.parent_collection_uris)
  end

  def related_items_q
    join_query_values(related_item_ids)
  end

  def related_item_ids
    begin
      doc = SolrDocument.find(related_item_source_id)
      doc[related_item_id_source_field]
    rescue SolrDocument::NotFound
      []
    end
  end

  def related_item_source_id
    split_related_item_values.first
  end

  def related_item_id_source_field
    split_related_item_values[1]
  end

  def related_item_id_target_field
    split_related_item_values.last
  end

  def split_related_item_values
    @split_related_item_values ||= blacklight_params[:id_related_items].split("|")
  end

  def join_query_values(values)
    "\"#{values.join('" "')}\"" if values.present?
  end

  def current_ability
    scope.current_ability
  end

  def gated_discovery_filters
    [resource_role_filters, policy_role_filters].compact
  end

  def policy_role_filters
    if policy_role_policies.present?
      local_parameter_query(Ddr::Index::Fields::IS_GOVERNED_BY, "policy_q")
    end
  end

  def resource_role_filters
    local_parameter_query(Ddr::Index::Fields::RESOURCE_ROLE, "resource_q")
  end

  def portal_filters
    local_parameter_query(Ddr::Index::Fields::IS_GOVERNED_BY, "portal_q")
  end

  def related_item_filters
    local_parameter_query(related_item_id_target_field, "related_items_q")
  end

  def local_parameter_query(default_field, param_name)
    "_query_:\"{!q.op=OR df=#{default_field} v=$#{param_name}}\""
  end

  # List of URIs for policies on which any of the current user's agent has a role in policy scope
  def policy_role_policies
    @policy_role_policies ||= Array.new.tap do |uris|
      policy_roles_results.each_with_object(uris) { |r, memo| memo << r[Ddr::Index::Fields::INTERNAL_URI] }
    end
  end

  def policy_roles_results
    ActiveFedora::SolrService.query(policy_roles_query, rows: Collection.count, fl: Ddr::Index::Fields::INTERNAL_URI)
  end

  def policy_roles_query
    "#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Collection AND (#{current_ability_agents})"
  end

  def current_ability_agents
    current_ability.agents.map do |agent|
      "#{Ddr::Index::Fields::POLICY_ROLE}:\"#{agent}\""
    end.join(" OR ")
  end


end
