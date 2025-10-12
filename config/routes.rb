Rails.application.routes.draw do
  root "home#index"
  get "classic", to: "home#index"
  get "storybook", to: "home#storybook_index"
  get "teen_content", to: "home#teen_content"

  # 강의 관련 라우트
  resources :courses do
    collection do
      get :search
    end
    member do
      post :enroll
      get :watch
    end
    resources :reviews, only: [ :create, :destroy ]
  end

  # 사용자 관련 라우트
  resources :users, except: [ :index ] do
    member do
      get :dashboard
      get :my_courses
      get :my_teachings
      patch :update_role  # 관리자 전용 role 업데이트 라우트
    end
  end

  # 세션 관리 (로그인/로그아웃)
  resource :session, only: [ :new, :create, :destroy ]
  get "login", to: "sessions#new"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy"
  get "signup", to: "users#new"

  # 장바구니
  resources :cart_items, only: [ :index, :create, :show, :destroy ] do
    collection do
      delete :clear
      post :enroll_all
      get :choice
    end
  end
  get 'cart_choice', to: 'cart_items#choice'
  
  # AI 이미지 생성
  resources :generated_images do
    member do
      post :retry
      get :status
    end
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
