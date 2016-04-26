Rails.application.routes.draw do
  root 'dashboard#index'

  devise_for :users, path: 'users', path_names: { sign_in: 'login', sign_out: 'logout' },
             controllers: {
                sessions: 'users/sessions',
                registrations: 'users/registrations',
                confirmations: 'users/confirmations',
                passwords: 'users/passwords',
                omniauth_callbacks: 'users/omniauth_callbacks'
             }

  ref_resources :users, :except => [:create, :new]

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # Serve websocket cable requests in-process
  # mount ActionCable.server => '/cable'
end
