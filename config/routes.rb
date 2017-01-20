Rails.application.routes.draw do
  resources :posts
  devise_for :users,controllers: { sessions: 'sessions' , registrations: 'users' }
  resources :users, only: [:create , :index , :update ,:show]

    match 'sendotp' => 'users#sendotp' ,via: [:post]
    match 'authenticateotp' => 'users#authenticateotp' ,via: [:post]


    match 'forgotsendotp' => 'users#forgotsendotp' ,via: [:post]
    match 'forgotauthenticateotp' => 'users#forgotauthenticateotp' ,via: [:post]





end
