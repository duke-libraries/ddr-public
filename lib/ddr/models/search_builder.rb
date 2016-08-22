module Ddr::Models
  #
  # Blacklight SearchBuilder methods.
  #
  # Include in controller search builder class:
  #
  #   class SearchBuilder < Blacklight::Solr::SearchBuilder
  #     include Ddr::Models::SearchBuilder
  #   end
  #
  module SearchBuilder


    def apply_access_controls(solr_parameters)
      solr_parameters[:fq] ||= []
      solr_parameters[:fq] << gated_discovery_filters.join(" OR ")
    end

    def current_ability
      scope.current_ability
    end

    # List of URIs for policies on which any of the current user's agent has a role in policy scope
    def policy_role_policies
      @policy_role_policies ||= Array.new.tap do |uris|
        filters = current_ability.agents.map do |agent|
          "#{Ddr::Index::Fields::POLICY_ROLE}:\"#{agent}\""
        end.join(" OR ")
        query = "#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Collection AND (#{filters})"
        results = ActiveFedora::SolrService.query(query, rows: Collection.count, fl: Ddr::Index::Fields::INTERNAL_URI)
        results.each_with_object(uris) { |r, memo| memo << r[Ddr::Index::Fields::INTERNAL_URI] }
      end
    end

    def policy_role_filters
      if policy_role_policies.present?
        rels = policy_role_policies.map { |pid| [:is_governed_by, pid] }
        ActiveFedora::SolrService.construct_query_for_rel(rels, "OR")
      end
    end

    def resource_role_filters
      current_ability.agents.map do |agent|
        ActiveFedora::SolrService.raw_query(Ddr::Index::Fields::RESOURCE_ROLE, agent)
      end.join(" OR ")
    end

    def gated_discovery_filters
      [resource_role_filters, policy_role_filters].compact
    end


  end
end
