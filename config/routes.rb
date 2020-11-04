Rails.application.routes.draw do
  mount ActionCable.server => '/cable'

  devise_for :users, controllers: { sessions: 'sessions', registrations: 'registrations' }
  resources :pages, only: :index

  root 'pages#index'
end
