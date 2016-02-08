Rails.application.routes.draw do

  root to: "catalog#index"

  blacklight_for :catalog

  get "dc/range_limit/", to: "digital_collections#range_limit"
  get "dc/facet/:id", to: "digital_collections#facet", as: "digital_collections_facet"
  constraints Collection do
    get "dc/:collection/featured", to: "digital_collections#featured", as: "featured_items"
    get "dc/:collection/about", :to => "digital_collections#about", as: "digital_collections_about"
    get "dc/:collection/:id/media", :to => "digital_collections#media"
    get "dc/:collection/:id", to: "digital_collections#show"
    get "dc/:collection", to: "digital_collections#index", as: "digital_collections"
  end
  get "dc" => "digital_collections#index"

  class Collection
    def self.matches?(request)
      Rails.application.config.portal.try(:[], 'portals').try(:[], 'collection_local_id').keys.include?(request.params[:collection])
    end
  end

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
