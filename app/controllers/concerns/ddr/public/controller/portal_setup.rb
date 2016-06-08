module Ddr
  module Public
    module Controller
      module PortalSetup
        extend ActiveSupport::Concern

        def self.included(base)
          base.before_action :prepend_view_path_for_portal_overrides
          base.solr_search_params_logic += [:include_only_specified_records]
        end


        private

        def include_only_specified_records(solr_parameters, user_parameters)
          if portal_controller_setup.parent_collection_uris
            field_value_pairs = portal_controller_setup.parent_collection_uris.map { |id| [:is_governed_by, id] }
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << ActiveFedora::SolrService.construct_query_for_rel(field_value_pairs, 'OR')
          end
        end

        def prepend_view_path_for_portal_overrides
          prepend_view_path portal_controller_setup.view_path
        end

        def portal_controller_setup
          portal_controller_setup ||= Portal::ControllerSetup.new({ controller_name: controller_name, local_id: params[:collection] })
        end

      end
    end
  end
end
