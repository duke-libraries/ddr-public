module Ddr
  module Public
    module Controller
      module DocumentContext
        extend ActiveSupport::Concern

        def children_item_documents
          configure_blacklight_for_children
          relationship ||= find_relationship(@document)

          query = ActiveFedora::SolrService.construct_query_for_rel([[relationship, @document[Ddr::Index::Fields::INTERNAL_URI]]])
          response, @children_item_documents = get_search_results(params.merge(rows: 9999), {q: query})
        end

        def item_count
          response, documents = get_search_results({:fl => 'id', :rows => 1, :q => "#{Ddr::Index::Fields::IS_GOVERNED_BY}:\"#{@document[Ddr::Index::Fields::INTERNAL_URI]}\" AND #{Ddr::Index::Fields::ACTIVE_FEDORA_MODEL}:Item" })
          @item_count = response.total
        end

        def parent_collection_document
          response, documents = get_search_results({:rows => 1, :q => "id:\"#{@document.admin_policy_id}\""})
          @parent_collection_document = documents.first
        end

        private

        def find_relationship document
          if @document.active_fedora_model == 'Item'
            relationship = :is_part_of
          elsif @document.active_fedora_model == 'Collection'
            relationship = :is_member_of_collection
          else
            return
          end
        end

        def configure_blacklight_for_children
          blacklight_config.configure do |config|
            config.sort_fields.clear
            config.add_sort_field "#{Ddr::Index::Fields::TITLE} asc", label: "Title"
            config.add_sort_field "#{Ddr::Index::Fields::LOCAL_ID} asc", label: "Local ID"
          end
        end

      end
    end
  end
end