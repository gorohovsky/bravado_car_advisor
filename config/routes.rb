Rails.application.routes.draw do
  resources :car_recommendations, only: :index, defaults: { format: :json }
end
