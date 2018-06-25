Rails.application.routes.draw do
  # user
  devise_for :users, controllers: {
    omniauth_callbacks: "omniauth_callbacks"
  }

  # diary
  resources :diarys, only: [:index, :show]
  root 'diarys#index'
end
