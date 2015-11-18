Rails.application.routes.draw do
  root :to => "welcome#index"

  get 'welcome/index'

  get 'nomnichi', to: 'articles#index'
  post 'articles/preview', to: 'articles#preview'
  resources :articles, except: :show
  get 'articles/search'
  get 'articles/:perma_link', to: 'articles#show'
  get 'articles/archive/:year(/:month)', to: 'articles#archive'
  resources :comments
  resources :articles
  get 'settings', to:  'users#edit'
  put 'users/:id/change_password', to: 'users#change_password'
  resources :users, except: :edit

  get "/auth/:provider/callback", to: "gate#omniauth"
  match "gate/login", :via => [:get, :post]
  get "gate/logout"
  get '*path', to: 'application#rescue_404'
end
