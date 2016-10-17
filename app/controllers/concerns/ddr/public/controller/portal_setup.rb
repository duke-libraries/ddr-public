module Ddr
  module Public
    module Controller
      module PortalSetup
        extend ActiveSupport::Concern

        def self.included(base)
          base.before_action :prepend_view_path_for_portal_overrides
          base.search_params_logic += [:filter_by_parent_collections]
        end

        def filter_by_parent_collections_query
          @filter_by_parent_collections_query ||= ActiveFedora::SolrService.construct_query_for_rel(parent_uris, ' OR ')
        end


        private

        def parent_uris
          Rails.cache.fetch("#{controller_name}/#{params[:collection]}/#{current_ability.user}", expires_in: 1.hour) do
            parent_collection_uris.map { |id| [:is_governed_by, id] }
          end
        end

        def prepend_view_path_for_portal_overrides
          @prepend_view_path_for_portal_overrides ||= prepend_view_path portal_controller_setup.view_path
        end

        def parent_collection_uris
          @parent_collection_uris = portal_controller_setup.parent_collection_uris
        end

        def portal_controller_setup
          portal_controller_setup ||= Portal::ControllerSetup.new({controller_name: controller_name,
                                                                   local_id: params[:collection],
                                                                   controller_scope: self })
        end

      end
    end
  end
end
