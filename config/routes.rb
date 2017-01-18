Rails.application.routes.draw do
  resources :posts
  devise_for :users, defaults: { format: :json } ,controllers: { sessions: 'sessions' , registrations: 'users' }
  resources :users, only: [:create , :index , :update ,:show]


end
