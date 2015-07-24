Rails.application.routes.draw do

  root to: "catalog#index"

  blacklight_for :catalog

  def pid_constraint
      /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/
  end
  
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}
  
  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', constraints: {id: pid_constraint}, as: 'download'

  # Permanent IDs
  get 'id/*permanent_id' => 'permanent_ids#show'

  get '/help', to: redirect(Ddr::Public.help_url)
  
  # Static Pages
  get '/styleguide' => 'pages#styleguide'
  get '/copyright' => 'pages#copyright', :as => 'copyright'

end
