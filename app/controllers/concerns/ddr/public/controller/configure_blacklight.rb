module Ddr
  module Public
    module Controller
      module ConfigureBlacklight
        extend ActiveSupport::Concern

        def self.included(base)
          base.before_action :configure_blacklight_facets
          base.before_action :configure_blacklight_show_fields
          base.before_action :configure_blacklight_index_fields
        end

        def configure_blacklight_facets
          configure_blacklight({
            clear_field: 'facet_fields',
            add_field: 'add_facet_field'})
        end

        def configure_blacklight_show_fields
          configure_blacklight({
            clear_field: 'show_fields',
            add_field: 'add_show_field'})
        end

        def configure_blacklight_index_fields
          configure_blacklight({
            clear_field: 'index_fields',
            add_field: 'add_index_field'})
        end

        def configure_blacklight options={}
          if conf = portal_config.try(:[], 'configure_blacklight').try(:[], options[:add_field])
            blacklight_config.send(options[:clear_field]).clear
            conf.each do |field|
              blacklight_config.send(options[:add_field],
                constantize_solr_field_string({solr_field: field['field']}),
                :label => field['label'],
                :show => field['show'],
                :collapse => field['collapse'],
                :limit => field['limit'],
                :sort => field['sort'],
                :range => field['range'],
                :helper_method => field['helper_method'],
                :link_to_search => if field['link_to_search'] then constantize_solr_field_string({solr_field: field['link_to_search']}) end
                )
            end
          end
        end

        def portal_config
          portal_config = Rails.application.config.try(:portal).try(:[], 'controllers').try(:[], params[:collection])
          portal_config ||= Rails.application.config.try(:portal).try(:[], 'controllers').try(:[], controller_name)
        end

        def constantize_solr_field_string options={}
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
