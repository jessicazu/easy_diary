Rails.application.routes.draw do
  # user
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks"
  }

  # diary
  resources :diaries, only: [:index, :show] do
  end
  root 'diaries#index'

  # webhook
  post '/callback' => 'webhook#callback'
end
