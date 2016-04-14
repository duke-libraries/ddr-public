Rails.application.routes.draw do

  root to: "catalog#index"

  blacklight_for :catalog

  # Range Limit and Facet routes for DC
  get "dc/range_limit/", to: "digital_collections#range_limit"
  get "dc/facet/:id", to: "digital_collections#facet", as: "digital_collections_facet"

  def local_id_contraint
    /[a-zA-Z0-9\-_]+/
  end
  
  # DC Collection scoped routes
  constraints(id: local_id_contraint, collection: local_id_contraint) do
    get "dc/:collection/featured", to: "digital_collections#featured", as: "featured_items"
    get "dc/:collection/about", :to => "digital_collections#about", as: "digital_collections_about"
    get "dc/:collection/:id/media", :to => "digital_collections#media", constraints: { format: 'json' }
    get "dc/:collection/:id/feed", :to => "digital_collections#feed", constraints: { format: 'xml' }
    get "dc/:collection/:id", to: "digital_collections#show"
    get "dc/:collection", to: "digital_collections#index", as: "digital_collections"
  end
  
  # Special named route just for DC Portal to distinguish
  # from DC collection portals
  get "dc" => "digital_collections#index_portal", as: "digital_collections_index_portal"

  # Must exist for facets to work from DC portal
  get "dc" => "digital_collections#index"

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
