unless Dir.glob(Rails.root.join('ddr-portals', '*/')).blank?
  portal_directories = Dir.glob(Rails.root.join('ddr-portals', '*/'))

  loaded_configs = {"portals" => {"collection_local_id" => {}, "admin_sets" => {}}, "controllers" => {}}

  portal_directories.each do |portal|
    portal_name = portal.split("/").last
    loaded_configs["controllers"][portal_name] = YAML.load_file(portal + 'portal_view_configs.yml')[Rails.env]
    portals_doc_configs = YAML.load_file(portal + 'portal_doc_configs.yml')[Rails.env]
    if portals_doc_configs["collection_local_id"]
      loaded_configs["portals"]["collection_local_id"].merge!(portals_doc_configs["collection_local_id"])
    end
    if portals_doc_configs["admin_sets"]
      loaded_configs["portals"]["admin_sets"].merge!(portals_doc_configs["admin_sets"])
    end
  end

  Rails.application.config.portal = loaded_configs
else
  Rails.application.config.portal = {}
end
