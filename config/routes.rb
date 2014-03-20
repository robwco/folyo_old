Folyo::Application.routes.draw do

  constraints(host: /^folyo.me$/) do
    match "/*path" => redirect {|params, req| "http://www.folyo.me/#{params[:path]}"}
  end

  match 'press' => 'site#press'
  match 'learn-more' => 'site#learn_more'
  match 'markdown' => 'site#markdown'
  match 'how-it-works' => 'site#learn_more'
  match 'about' => 'site#about'
  match 'guides' => 'site#guides'
  match 'partners' => 'site#partners'
  match 'apply' => 'site#apply'

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
    match "/sign_up/:initial_role/job" => 'users/registrations#new', as: 'new_user_with_role', job: true
    match "/sign_up/:initial_role" => 'users/registrations#new',     as: 'new_user_with_role'
  end

  namespace :admin do
    resources :designers do
      get 'messages',    on: :collection
      put 'to_markdown', on: :member
      get 'accepted_email', on: :member
      get 'rejected_email', on: :member
    end
    resources :clients do
      put 'to_markdown', on: :member
    end
    resources :job_offers, path: 'offers', as: 'offers' do
      resource :order do
        put 'refund'
      end
      get 'waiting_for_submission',     on: :collection
      get 'waiting_for_payment',        on: :collection
      get 'waiting_for_review',         on: :collection
      get 'rejected',                   on: :collection
      get 'accepted',                   on: :collection
      get 'archived',                   on: :collection
      get 'refunded',                   on: :collection
      put 'accept',                     on: :member
      put 'reject',                     on: :member
      put 'to_markdown',                on: :member
    end
    resource :dashboard, controller: 'Dashboard'
    resources :newsletters do
      get 'webhook', on: :collection
      post 'webhook', on: :collection
      delete 'offer', on: :member
    end
  end

  resources :designers do
    get 'map',                    on: :collection
    get 'san_francisco_bay_area', on: :collection
    get 'notifications',          on: :member
    get 'reapply',                on: :member
    resources :messages
    resources :designer_projects, path: 'projects', as: 'projects' do
      resources :designer_project_artworks, path: 'artworks', as: 'artworks' do
        get 'crop',          on: :member
        put 'update_crop',   on: :member
        get 'status',        on: :member
      end
    end
    resource :profile_picture do
      get 'crop'
      put 'update_crop'
      get 'status'
    end
    resources :referrals do
      put 'transfer', on: :collection
    end
  end

  resources :clients

  resources :job_offers, path: 'offers', as: 'offers' do
    get 'history',      on: :collection
    get 'archives',     on: :collection
    get 'show_archive', on: :member
    post 'archive',     on: :member
    resource :order do
      get 'checkout'
      get 'confirm'
    end
    resources :designer_replies, path: 'replies', as: 'replies' do
      put 'shortlist', on: :member
      put 'hide',      on: :member
      get 'mail',      on: :member
    end
    resource :evaluations
  end

  get '/referrals', controller: 'referrals', action: 'index_for_current_user'

  get 'account', controller: 'application', action: 'account'

  root to: "site#home"

  mount Jobbr::Engine => "/jobbr"

end
