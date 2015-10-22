Rails.application.routes.draw do

  root to: "catalog#index"

  blacklight_for :catalog

  scope 'dc' do
    Rails.application.config.portal_controllers['portals']['digital_collections']['include']['collections'].each do |collection_controller_name|
      get "#{collection_controller_name}/range_limit", :to => "#{collection_controller_name}#range_limit"
      get "#{collection_controller_name}/facet/:id", to: "#{collection_controller_name}#facet", as: "#{collection_controller_name}_facet"
      get "#{collection_controller_name}/about", to: "#{collection_controller_name}#about", as: "about_#{collection_controller_name}"
      get "#{collection_controller_name}/:id", to: "#{collection_controller_name}#show"
      get "#{collection_controller_name}", to: "#{collection_controller_name}#index"
    end
  end
  
  get 'dc/about', to: 'digital_collections#about', as: 'about_digital_collections'
  resources :digital_collections, path: 'dc', only: [:index, :show]

  resources :nescent, only: [:index, :show]

  def pid_constraint
      /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/
  end
  
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}
  
  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', constraints: {id: pid_constraint}, as: 'download'
  post 'download/images/:id' => 'catalog#zip_images'
  post 'download/images-pdf/:id' => 'catalog#pdf_images'

  # Permanent IDs
  get 'id/*permanent_id' => 'permanent_ids#show'

  get '/help', to: redirect(Ddr::Public.help_url)
  
  # Static Pages
  get '/styleguide' => 'pages#styleguide'
  get '/copyright' => 'pages#copyright', :as => 'copyright'

end
