module Ddr
  module Public
    module Controller
      module SolrQueryConstructor
        extend ActiveSupport::Concern

        def get_solr_search_results(args)
          get_search_results(args)
        end

        def children_query(values)
          ActiveFedora::SolrService.construct_query_for_rel(field_value_pairs(:is_governed_by, values), 'OR')
        end

        def admin_set_query(values)
          construct_query(field_value_pairs(Ddr::Index::Fields::ADMIN_SET, values), 'OR')
        end

        def active_fedora_model_query(values)
          construct_query(field_value_pairs(Ddr::Index::Fields::ACTIVE_FEDORA_MODEL, values), 'OR')
        end

        def local_ids_query(values)
          construct_query(field_value_pairs(Ddr::Index::Fields::LOCAL_ID, values), 'OR')
        end

        def construct_query(field_pairs, join_string="AND")
          field_pairs = field_pairs.to_a if field_pairs.kind_of? Hash
          field_pairs.map { |field, value| ActiveFedora::SolrService.raw_query(field, value)  }.join(" #{join_string} ")
        end

        def field_value_pairs(field, values)
          values.map { |value| [field, value] }
        end

        def constantize_solr_field_name options={}
          if options[:solr_field].respond_to? :each
            ActiveFedora::SolrService.solr_name(*options[:solr_field]).to_s
          else
            options[:solr_field].safe_constantize.to_s
          end
        end

      end
    end
  end
end
