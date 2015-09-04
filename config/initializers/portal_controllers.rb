# # config_file = File.join Rails.root, "/config/collections_config.yml"
# # APP_CONFIG = YAML.load_file(config_file)[Rails.env]

def add_collection_includes_to_portals(portal_configs)
  collection_includes = get_collection_includes_from_collections(portal_configs)
  if collection_includes.length > 0
    collection_includes.each do |portal_name, fields|
      fields.each do |field_name, values|
        unless portal_configs['portals'][portal_name]['include'][field_name]
          portal_configs['portals'][portal_name]['include'][field_name] = []
        end
        portal_configs['portals'][portal_name]['include'][field_name].concat values
      end
    end
  end
  portal_configs
end

def get_collection_includes_from_collections(portal_controllers_config_file)
  collection_includes = {}
  if portal_controllers_config_file['portals']
    portal_controllers_config_file['portals'].each do |portal_controller_name, portal_config|
      if portal_config['include']['collections']
        fields = {}
        portal_config['include']['collections'].each do |value|
          portal_controllers_config_file['collections'][value]['include'].each do |field, values|
            unless fields[field]
              fields[field] = []
            end
            fields[field].concat values
          end
        end
        collection_includes = { portal_controller_name => fields }
      end
    end
  end
  collection_includes
end


portal_controllers_config_file = YAML.load_file(Rails.root.join('config', 'portal_controllers.yml'))[Rails.env]

Rails.application.config.portal_controllers = add_collection_includes_to_portals(portal_controllers_config_file)
