Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
  namespace :api do
    namespace :v1 do
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :products, only: [:index, :show, :create, :update, :destroy]
      # Todo: Use Event-Driven Architecture (message queue such as RabbitMQ, Kafka, Redis or Amazon SNS & Amazon SQS) in practice
      patch "/products/:id/update_stock", to: "products#update_stock"
      patch "/products/update_stock/batch", to: "products#update_stock_batch"
    end
  end
end
