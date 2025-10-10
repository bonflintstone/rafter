Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "track#index"

  get "/share" => "track#share", as: :share
end
