module Ddr
  module Public
    module Controller
      module Portal
        extend ActiveSupport::Concern

        include Ddr::Public::Controller::SolrQueryConstructor
          
        def self.included(base)
          base.before_action :prepend_view_path_for_portal_overrides
          base.before_action :parent_collection_uris
          
          base.solr_search_params_logic += [:include_only_specified_records]
        end

        private

        def collection_document
          if parent_collection_documents.length == 1
            @collection_document ||= parent_collection_documents.first
          end
        end

        def showcase_documents
          @showcase_documents ||= image_documents_search('showcase_images')
        end

        def showcase_custom_images
          @showcase_custom_images ||= portal_config.try(:[], 'showcase_images').try(:[], 'custom_images')
        end
        
        def showcase_layout
          @showcase_layout ||= portal_config.try(:[], 'showcase_images').try(:[], 'layout')
        end

        def highlight_documents
          @highlight_documents ||= image_documents_search('highlight_images')
        end

        def highlight_count
          @highlight_count ||= portal_config.try(:[], 'highlight_images').try(:[], 'display')
        end

        def show_items
          @show_items ||= portal_config.try(:[], 'show_items')
        end

        def featured_collection_documents
          @featured_collection_documents ||= image_documents_search('featured_collections')
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
            field_value_pairs = @parent_collection_uris.map { |id| [:is_governed_by, id] }
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << ActiveFedora::SolrService.construct_query_for_rel(field_value_pairs, 'OR')
          end
        end

        def parent_collection_uris
          @parent_collection_uris ||= parent_collection_documents.map { |document| document.internal_uri }
        end

        def parent_collection_documents
          @parent_collection_documents ||= parent_collection_search
        end

        def children_documents
          response, @children_documents = children_search()
          @item_count = response.total
        end

        def children_search
          query = "(#{children_query(@parent_collection_uris)}) AND #{active_fedora_model_query(['Item'])}"
          get_search_results({:q => query})
        end

        def parent_collection_search
          response, document_list = get_search_results({:q => parent_collection_query })
          @collection_count = response.total
          document_list
        end

        def image_documents_search(field)
          image_documents ||= []
          if portal_config[field].try(:[], 'local_ids')            
            query = "(#{local_ids_query(image_config(field))}) AND (#{active_fedora_model_query(['Collection', 'Item'])})"
            response, image_documents = get_search_results({:q => query})
          end
          image_documents
        end

        def parent_collection_query
          local_id_config ? local_ids_query(local_id_config()) : admin_set_query(admin_set_config())
        end

        def image_config(field)
          portal_config[field]['local_ids']
        end

        def admin_set_config
          portal_config['includes']['admin_sets']
        end

        def local_id_config
          portal_config['includes']['local_ids']
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
