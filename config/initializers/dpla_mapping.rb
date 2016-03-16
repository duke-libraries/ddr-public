Rails.application.config.dpla_mapping = YAML.load_file(Rails.root.join('config', 'dpla_mapping.yml')).deep_symbolize_keys
