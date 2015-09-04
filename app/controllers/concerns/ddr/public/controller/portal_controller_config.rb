
module Ddr
  module Public
    module Controller
      module PortalControllerConfig
        extend ActiveSupport::Concern
          
        def self.included(base)
          base.before_filter :set_showcase_images_before_filter, only: [:index, :facet]
          base.before_filter :get_document_uris_from_admin_sets_and_local_ids

          base.solr_search_params_logic += [:include_only_specified_records]
        end

        private

        def set_showcase_images_before_filter
          if portals_and_collections[controller_name]['showcase_images']
            slideshow_identifiers = portals_and_collections[controller_name]['showcase_images']
            response, @collection_showcase_document_list = get_search_results({:q => construct_solr_parameter_value({:solr_field => 'identifier_tesim', :boolean_operator => "OR", :values => slideshow_identifiers})})
          end
        end

        def include_only_specified_records(solr_parameters, user_parameters)
          if @parent_collections_uris
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << construct_solr_parameter_value({:solr_field => Ddr::IndexFields::IS_GOVERNED_BY, :boolean_operator => "OR", :values => @parent_collections_uris})
          end
        end

        def get_document_uris_from_admin_sets_and_local_ids
          if portals_and_collections[controller_name]['include']['admin_sets']
            get_document_uris({:field => Ddr::IndexFields::ADMIN_SET, :config_values => portals_and_collections[controller_name]['include']['admin_sets']})
          end
          if portals_and_collections[controller_name]['include']['local_ids']
            get_document_uris({:field => Ddr::IndexFields::IDENTIFIER_ALL, :config_values => portals_and_collections[controller_name]['include']['local_ids']})
          end
        end

        def get_document_uris opts = {}
          @parent_collections_uris ||= []
          response, document_list = get_search_results({:q => construct_solr_parameter_value({:solr_field => opts[:field], :boolean_operator => "OR", :values => opts[:config_values]})})
          @parent_collections_uris = document_list.map { |document| document.internal_uri}
        end

        def portals_and_collections
          Rails.application.config.portal_controllers['portals'].merge Rails.application.config.portal_controllers['collections']
        end

      end
    end
  end
end
