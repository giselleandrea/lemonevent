Rails.application.routes.draw do
  post 'auth/login', to: 'authentication#authenticate'
  post 'user/signup', to: 'users#create'

  get 'events/events', to: 'events#index'
  get 'events/event/:id', to: 'events#show'
  post 'events/create', to: 'events#create'
  put 'events/update/:id', to: 'events#update'
  delete 'events/delete/:id', to: 'events#destroy'


  # Ruta para servir el frontend React
  get '*path', to: 'static#index', constraints: ->(request) { !request.xhr? && request.format.html? }

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
