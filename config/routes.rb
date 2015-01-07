Rails.application.routes.draw do
  root :to => "catalog#index"
  blacklight_for :catalog
  devise_for :users

  def pid_constraint
      /[a-zA-Z0-9\-_]+:[a-zA-Z0-9\-_]+/
  end
  
  resources :thumbnail, only: :show, constraints: {id: pid_constraint}
  
  # Downloads
  get 'download/:id(/:datastream_id)' => 'downloads#show', :constraints => {id: pid_constraint}, as: 'download'

  # Permanent IDs
  get 'id/*permanent_id' => 'permanent_ids#show'

end
