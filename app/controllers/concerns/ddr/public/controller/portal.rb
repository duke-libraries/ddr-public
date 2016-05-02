module Ddr
  module Public
    module Controller
      module Portal
        extend ActiveSupport::Concern

        #include Ddr::Public::Controller::SolrQueryConstructor
          
        def self.included(base)
          base.before_action :prepend_view_path_for_portal_overrides
                    
          base.solr_search_params_logic += [:include_only_specified_records]
        end

        private

        def include_only_specified_records(solr_parameters, user_parameters)
          if @portal.parent_collection_uris
            field_value_pairs = @portal.parent_collection_uris.map { |id| [:is_governed_by, id] }
            solr_parameters[:fq] ||= []
            solr_parameters[:fq] << ActiveFedora::SolrService.construct_query_for_rel(field_value_pairs, 'OR')
          end
        end

        def prepend_view_path_for_portal_overrides
          prepend_view_path @portal.view_path
        end

        # TODO: Functionality below should be removed once
        #       Views are updated to use @portal

        def collection_document
          if  @portal.parent_collections.count == 1
            @collection_document ||= @portal.parent_collections.documents.first
          end
          @collection_count = @portal.parent_collections.count
        end

        def showcase_documents
          @showcase_documents = @portal.features.showcase.documents
        end

        # TODO: Combine with showcase documents
        def showcase_custom_images
          @showcase_custom_images = @portal.showcase_custom_images
        end
        
        def showcase_layout
          @showcase_layout = @portal.features.showcase.layout
        end

        def highlight_documents
          @highlight_documents = @portal.features.highlights.documents
        end

        def highlight_count
          @highlight_count = @portal.features.highlights.limit
        end

        def show_items
          @show_items = @portal.features.items.limit
        end

        def featured_collection_documents
          @featured_collection_documents = @portal.features.collections.documents
        end

        def max_download
          @max_download = @portal.restrictions.max_download
        end

        def blog_posts_url
          @blog_post_url = @portal.blog_posts_url
        end

        def alert_message
          @portal_alert_message = @portal.alert_message
        end

        def derivative_url_prefixes
          @derivative_url_prefixes = @portal.derivative_url_prefixes
        end

        def item_relators
          @item_relators = @portal.item_relators
        end

        def parent_collection_uris
          @parent_collection_uris = @portal.parent_collection_uris
        end

        def children_documents
          @children_documents = @portal.child_items.documents
          @item_count = @portal.child_items.count
        end

      end
    end
  end
end
