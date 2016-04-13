module Ddr
  module Public
    module Controller
      module ConstantizeSolrFieldName
        extend ActiveSupport::Concern

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
    