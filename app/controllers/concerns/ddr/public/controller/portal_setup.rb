module Ddr
  module Public
    module Controller
      module PortalSetup
        extend ActiveSupport::Concern

        def self.included(base)
          base.before_action :prepend_view_path_for_portal_overrides
          base.search_params_logic += [:filter_by_parent_collections]
        end

        def parent_collection_uris
          @parent_collection_uris ||= portal_controller_setup.parent_collection_uris
        end


        private

        def prepend_view_path_for_portal_overrides
          @prepend_view_path_for_portal_overrides ||= prepend_view_path portal_controller_setup.view_path
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
