Rails.application.routes.draw do

  root to: "catalog#index"

  blacklight_for :catalog

  get 'digital_collections/:id/details', :to => 'digital_collections#details', :as => 'details'
  get '/digital_collections/about', to: 'digital_collections#about', as: 'about_digital_collections'
  resources :digital_collections, only: [:index, :show]

  def pid_constraint
      /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/
  end
  
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}
  
  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', constraints: {id: pid_constraint}, as: 'download'
  post 'download/images/:id' => 'catalog#zip_images'

  # Permanent IDs
  get 'id/*permanent_id' => 'permanent_ids#show'

  get '/help', to: redirect(Ddr::Public.help_url)
  
  # Static Pages
  get '/styleguide' => 'pages#styleguide'
  get '/copyright' => 'pages#copyright', :as => 'copyright'

end
