Rails.application.routes.draw do

  # root to: "catalog#index"

  blacklight_for :catalog

  def id_constraint
    /[a-zA-Z0-9\/\-_%]+:?[a-zA-Z0-9\/\-_%]*/
  end

  constraints(id: id_constraint) do
    get "directory_tree/:id/:directory_id", to: "directory_tree#show", as: "directory_tree_node"
    defaults directory_id: "root" do
      get "directory_tree/:id", to: "directory_tree#show", as: "directory_tree_root"
    end
  end

  # Range Limit and Facet routes for DC
  get "dc/range_limit/", to: "digital_collections#range_limit"
  get "dc/facet/:id", to: "digital_collections#facet", as: "digital_collections_facet"

  # DC Collection scoped routes
  constraints(id: id_constraint, collection: id_constraint) do
    get "dc/:collection/range_limit/", to: "digital_collections#range_limit"
    get "dc/:collection/facet/:id", to: "digital_collections#facet"
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

  # Range Limit and Facet routes for DC
  get "portal/range_limit/", to: "portal#range_limit"
  get "portal/facet/:id", to: "portal#facet", as: "portal_facet"

  # DC Collection scoped routes
  constraints(id: id_constraint, collection: id_constraint) do
    get "portal/:collection/about", :to => "portal#about", as: "portal_about"
    get "portal/:collection/:id", to: "portal#show"
    get "portal/:collection", to: "portal#index", as: "portal"
  end

  # Special named route just for DC Portal to distinguish
  # from DC collection portals
  get "portal" => "portal#index_portal", as: "portal_index_portal"

  # Must exist for facets to work from DC portal
  get "portal" => "portal#index"




  resources :thumbnail, only: :show, constraints: {id: id_constraint}

  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', as: 'download', constraints: {id: id_constraint}
  post 'download/images/:id' => 'catalog#zip_images'
  post 'download/images-pdf/:id' => 'catalog#pdf_images'

  # Streamable Media
  get 'stream/:id' => 'stream#show', as: 'stream', constraints: {id: id_constraint}

  # Captions
  get 'captions/:id/txt' => 'captions#text', as: 'captions_txt', constraints: {id: id_constraint}
  get 'captions/:id/pdf' => 'captions#pdf', as: 'captions_pdf', constraints: {id: id_constraint}
  get 'captions/:id' => 'captions#show', as: 'captions', constraints: {id: id_constraint}

  # Permanent IDs
  get 'id/*permanent_id' => 'permanent_ids#show'

  get '/help', to: redirect(Ddr::Public.help_url)

  # Static Pages
  get '/styleguide' => 'pages#styleguide'
  get '/copyright' => 'pages#copyright', :as => 'copyright'
  get '/homepage' => 'pages#homepage'


  root to: "pages#homepage"

end
