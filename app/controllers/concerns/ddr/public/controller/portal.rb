module Ddr
  module Public
    module Controller
      module Portal
        extend ActiveSupport::Concern

        include Ddr::Public::Controller::ConstantizeSolrFieldName
          
        def self.included(base)
          base.before_action :prepend_view_path_for_portal_overrides
          base.before_action :parent_collection_uris
          
          base.solr_search_params_logic += [:include_only_specified_records]
        end

        private

        def collection_document
          if parent_collection_document_list.length == 1
            @collection_document ||= parent_collection_document_list.first
          end
        end

        def showcase_documents
          @showcase_documents ||= image_documents('showcase_images')
        end

        def showcase_custom_images
          @showcase_custom_images ||= portal_config.try(:[], 'showcase_images').try(:[], 'custom_images')
        end
        
        def showcase_layout
          @showcase_layout ||= portal_config.try(:[], 'showcase_images').try(:[], 'layout')
        end

        def highlight_documents
          @highlight_documents ||= image_documents('highlight_images')
        end

        def highlight_count
          @highlight_count ||= portal_config.try(:[], 'highlight_images').try(:[], 'display')
        end

        def featured_collection_documents
          @featured_collection_documents ||= image_documents('featured_collections')
        end

        def max_download
          @max_download ||= portal_config.try(:[], 'restrictions').try(:[], 'max_download')
        end

        def blog_posts_url
          @blog_post_url ||= portal_config.try(:[], 'blog_posts')
        end

        def alert_message
          @portal_alert_message ||= portal_config.try(:[], 'alert')
        end

        def derivative_url_prefixes
          @derivative_url_prefixes ||= portal_config.try(:[], 'derivative_url_prefixes')
        end

        def item_relators
          @item_relators ||= portal_config.try(:[], 'item_relators')
        end

        def include_only_specified_records(solr_parameters, user_parameters)
          if @parent_collection_uris
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << construct_solr_parameter_value({:solr_field => Ddr::Index::Fields::IS_GOVERNED_BY, :boolean_operator => "OR", :values => @parent_collection_uris})
          end
        end

        def parent_collection_uris
          @parent_collection_uris ||= parent_collection_document_list.map { |document| document.internal_uri }
        end

        def parent_collection_document_list
          @parent_collection_documents ||= parent_collection_search
        end

        def collection_count
          @collection_count = @parent_collection_documents.count
        end

        def item_count
          response, documents = get_search_results({ :q => "(#{construct_solr_parameter_value({:solr_field => Ddr::Index::Fields::IS_GOVERNED_BY, :boolean_operator => "OR", :values => @parent_collection_uris})}) AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item" })
          @item_count = response.total
        end

        def parent_collection_search
          opts = parent_collection_configs
          response, document_list = get_search_results({:q => construct_solr_parameter_value({:solr_field => opts[:field], :boolean_operator => "OR", :values => opts[:config_values]})})
          document_list
        end

        def parent_collection_configs
          configs ||= {}
          if portal_config['includes']['admin_sets']
            configs = {:field => Ddr::Index::Fields::ADMIN_SET, :config_values => portal_config['includes']['admin_sets']}
          end
          if portal_config['includes']['local_ids']
            query = portal_config['includes']['local_ids'].map { |value| "#{Ddr::Index::Fields::LOCAL_ID}:#{value}" }.join(" OR ")
            response, document_list = get_search_results({:q => "(#{query}) AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Collection"})
            parent_pids = document_list.map { |document| document.pid }
            configs = {:field => Ddr::Index::Fields::ID, :config_values => parent_pids}
          end
          configs
        end

        def image_documents(field)
          image_documents ||= []
          if portal_config[field].try(:[], 'local_ids')
            query = portal_config[field]['local_ids'].map { |value| "#{Ddr::Index::Fields::LOCAL_ID}:#{value}" }.join(" OR ")
            response, image_documents = get_search_results({:q => "(#{query}) AND (#{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item OR #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Collection)"})
          end
          image_documents
        end

        def portal_config
          portal_config = Rails.application.config.portal.try(:[], 'controllers').try(:[], params[:collection])
          portal_config ||= Rails.application.config.portal.try(:[], 'controllers').try(:[], controller_name)
        end

        def prepend_view_path_for_portal_overrides
          prepend_view_path "app/views/ddr-portals/#{params[:collection] || controller_name}"
        end

      end
    end
  end
end
