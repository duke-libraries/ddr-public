module Ddr
  module Public
    module Controller
      module ConfigureBlacklight
        extend ActiveSupport::Concern

        include Ddr::Public::Controller::SolrQueryConstructor

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
          if conf = portal_blacklight_config.try(:[], options[:add_field])
            blacklight_config.send(options[:clear_field]).clear
            conf.each do |field|
              blacklight_config.send(options[:add_field],
                constantize_solr_field_name({solr_field: field['field']}),
                :label => field['label'],
                :show => field['show'],
                :separator => field['separator'],
                :collapse => field['collapse'],
                :limit => field['limit'],
                :sort => field['sort'],
                :range => field['range'],
                :helper_method => field['helper_method'],
                :accessor => field['accessor'],
                :link_to_search => if field['link_to_search'] then constantize_solr_field_name({solr_field: field['link_to_search']}) end
                )
            end
          end
        end

        def portal_blacklight_config
          portal_blacklight_config ||= BlacklightConfiguration.new({ controller_name: controller_name, local_id: params[:collection] })
          portal_blacklight_config.configuration
        end
        
      end
    end
  end
end
