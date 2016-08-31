def configure_ddr_public_portals
  formatted_configs = config_format()

  portal_directories.each do |portal_directory|

    formatted_configs["controllers"][portal_name(portal_directory)] = load_portal_view_configs(portal_directory)

    if portal_doc_configs = load_portal_doc_configs(portal_directory)
      formatted_configs["portals"]["collection_local_id"].merge!(portal_doc_configs["collection_local_id"] || {})
      formatted_configs["portals"]["admin_sets"].merge!(portal_doc_configs["collection_admin_set"] || {})
    end

  end

  formatted_configs
end

def portal_name(portal_directory)
  portal_directory.split("/").last
end

def load_portal_view_configs(portal_directory)
  YAML.load_file("#{portal_directory}portal_view_configs.yml")
end

def load_portal_doc_configs(portal_directory)
  file_path = "#{portal_directory}portal_doc_configs.yml"
  if File.exist?(file_path)
    YAML.load_file(file_path)
  end
end

def portal_directories
  Dir.glob(Rails.root.join('ddr-portals', '*/'))
end

def config_format
  {"portals" => {"collection_local_id" => {}, "admin_sets" => {}}, "controllers" => {}}
end



if Dir.glob(Rails.root.join('ddr-portals', '*/')).blank?
  Rails.application.config.portal = {}
else
  Rails.application.config.portal = configure_ddr_public_portals()
end
