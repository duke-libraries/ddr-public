
module Ddr
  module Public
    module Controller
      module PortalControllerConfig
        extend ActiveSupport::Concern
          
        def self.included(base)
          base.before_filter :showcase_image_document_list, only: [:index, :facet]
          base.before_filter :highlight_image_document_list, only: [:index, :facet]          
          base.before_filter :get_document_uris_from_admin_sets_and_local_ids
          base.before_filter :search_scope_options

          base.solr_search_params_logic += [:include_only_specified_records]
        end

        private

        def showcase_image_document_list
          @collection_showcase_document_list = get_document_list_from_configuration("showcase")
        end
        
        def highlight_image_document_list
          @collection_highlight_document_list = get_document_list_from_configuration("highlight")
        end

        def get_document_list_from_configuration config_field
          if portals_and_collections[controller_name][config_field] && portals_and_collections[controller_name][config_field]['local_ids']
            highlight_ids = portals_and_collections[controller_name][config_field]['local_ids']
            query = {:q => construct_solr_parameter_value({:solr_field => Ddr::Index::Fields::ACTIVE_FEDORA_MODEL, :values => ["Component"]} ) + " AND (" + construct_solr_parameter_value({:solr_field => Ddr::Index::Fields::LOCAL_ID, :boolean_operator => "OR", :values => highlight_ids}) + ")"}
            response, document_list = get_search_results(query, :rows => 40)
            document_list
          end
        end

        def include_only_specified_records(solr_parameters, user_parameters)
          if @parent_collections_uris
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << construct_solr_parameter_value({:solr_field => Ddr::Index::Fields::IS_GOVERNED_BY, :boolean_operator => "OR", :values => @parent_collections_uris})
          end
        end

        def search_scope_options
          @search_scopes = []
          @search_scopes << :search_action_url
          portals_and_collections.each do |portal_controller_name, value|
            if value['include']['collections'].present?
               if value['include']['collections'].include? controller_name
                 @search_scopes << portal_controller_name.to_sym   
               end
            end
          end
          @search_scopes << :catalog_index_url
        end

        def get_document_uris_from_admin_sets_and_local_ids
          if portals_and_collections[controller_name]['include']['admin_sets']
            get_document_uris({:field => Ddr::Index::Fields::ADMIN_SET, :config_values => portals_and_collections[controller_name]['include']['admin_sets']})
          end
          if portals_and_collections[controller_name]['include']['local_ids']
            get_document_uris({:field => Ddr::Index::Fields::IDENTIFIER_ALL, :config_values => portals_and_collections[controller_name]['include']['local_ids']})
          end
        end

        def get_document_uris opts = {}
          @parent_collections_uris ||= []
          response, document_list = get_search_results({:q => construct_solr_parameter_value({:solr_field => opts[:field], :boolean_operator => "OR", :values => opts[:config_values]})})
          @parent_collections_uris = document_list.map { |document| document.internal_uri}
          if document_list.length == 1
            @collection_document = document_list.first
          end
        end

        def portals_and_collections
          Rails.application.config.portal_controllers['portals'].merge Rails.application.config.portal_controllers['collections']
        end

      end
    end
  end
end
