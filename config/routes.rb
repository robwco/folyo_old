Folyo::Application.routes.draw do

  constraints(host: /^folyo.me$/) do
    get "/*path" => redirect {|params, req| "http://www.folyo.me/#{params[:path]}"}
  end

  get 'press' => 'site#press'
  get 'learn-more' => 'site#learn_more'
  get 'markdown' => 'site#markdown'
  get 'how-it-works' => 'site#learn_more'
  get 'about' => 'site#about'
  get 'estimate' => 'site#estimate'
  get 'guides' => 'site#guides'
  get 'partners' => 'site#partners'
  get 'apply' => 'site#apply'

  resource :guides do
    get 'how_to_pick_a_designer' => redirect('/guides/how_to_pick_a_great_designer')
    get 'how_to_pick_a_great_designer'
    get 'how_to_write_a_good_job_description'
    get 'quora-redesign' => redirect('/guides/quora_redesign')
    get 'quora_redesign'
    get 'quora_redesign_screenshot'
    get 'quora-redesign-screenshot' => redirect('/guides/quora_redesign_screenshot')
  end

  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    get "sign_in", to: 'devise/sessions#new'
    get "sign_up", to: 'users/registrations#new'
    get "/sign_up/:initial_role/job" => 'users/registrations#new', job: true
    get "/sign_up/:initial_role" => 'users/registrations#new',     as: 'new_user_with_role'
  end

  namespace :admin do
    resources :designers do
      get 'messages',         on: :collection
      get 'pending',          on: :collection
      get 'profile',          on: :member
      get 'dribbble_profile', on: :member
      get 'reject',           on: :member
      get 'accepted_email',   on: :member
      get 'rejected_email',   on: :member
    end
    resources :clients
    resources :job_offers, path: 'offers', as: 'offers' do
      resource :order do
        patch 'refund'
      end
      get   'waiting_for_submission',     on: :collection
      get   'waiting_for_payment',        on: :collection
      get   'waiting_for_review',         on: :collection
      get   'rejected',                   on: :collection
      get   'accepted',                   on: :collection
      get   'archived',                   on: :collection
      get   'refunded',                   on: :collection
      patch 'accept',                     on: :member
      patch 'reject',                     on: :member
    end
    resource :dashboard, controller: 'dashboard'
    resources :referral_programs
  end

  resources :designers do
    get 'map',                    on: :collection
    get 'san_francisco_bay_area', on: :collection
    get 'reapply',                on: :member
    resources :messages
    resources :designer_projects, path: 'projects', as: 'projects' do
      resources :designer_project_artworks, path: 'artworks', as: 'artworks' do
        get 'crop',               on: :member
        patch 'update_crop',        on: :member
        get 'status',             on: :member
      end
    end
    resource :profile_picture do
      get 'crop'
      patch 'update_crop'
      get 'status'
    end
    resources :referrals do
      patch 'transfer', on: :collection
    end
    get 'skills',                 on: :member
  end

  resources :clients

  resources :job_offers, path: 'offers', as: 'offers' do
    get 'history',      on: :collection
    get 'show_archive', on: :member
    post 'archive',     on: :member
    get 'mail',         on: :member
    resource :order do
      get 'checkout'
      get 'confirm'
    end
    resources :designer_replies, path: 'replies', as: 'replies' do
      patch 'shortlist', on: :member
      get   'shortlist', on: :member
      patch 'hide',      on: :member
      get   'hide',      on: :member
      get   'mail',      on: :member
    end
    resource :evaluations
  end

  resources :surveys do

    get   '/:survey_name/(:page)', on: :collection, to: 'surveys#show'
    patch '/:survey_name/(:page)', on: :collection, to: 'surveys#update'

  end

  get '/referrals', controller: 'referrals', action: 'index_for_current_user'

  get 'account/(:account_section)', controller: 'application', action: 'account', as: 'account'

  root to: "site#home"

  authenticate :user, lambda { |u| u.is_a?(Admin) } do
    require 'sidekiq/web'
    mount Jobbr::Engine => '/jobbr'
    mount Sidekiq::Web  => '/sidekiq'
  end

end
