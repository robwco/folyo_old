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
      get 'posts',       on: :collection
      get 'messages',    on: :collection
      put 'to_markdown', on: :member
    end
    resources :clients do
      put 'to_markdown', on: :member
    end
    resources :job_offers, path: 'offers', as: 'offers' do
      resources :replies
      resource :order do
        put 'refund'
      end
      get 'active',           on: :collection
      get 'archived',         on: :collection
      get 'rejected',         on: :collection
      get 'refunded',         on: :collection
      get 'newsletter_setup', on: :collection
      put 'accept',           on: :member
      put 'reject',           on: :member
      put 'to_markdown',      on: :member
    end
    resource :dashboard, controller: 'Dashboard'
  end

  # supporting old Folyo url with PostgreSQL ids
  match 'designers/:id' => 'designers#show_by_pg_id', :id => /\d{1,4}/

  resources :designers do
    get 'map',                    on: :collection
    get 'san_francisco_bay_area', on: :collection
    get 'notifications',          on: :member
    get 'reapply',                on: :member
    resources :messages
    resources :designer_posts, path: 'posts', as: 'posts'
  end

  resources :clients

  # supporting old Folyo url with PostgreSQL ids
  match 'client/offers/:id' => 'job_offers#show_by_pg_id', :id => /\d{1,4}/

  resources :job_offers, path: 'offers', as: 'offers' do
    get 'history',      on: :collection
    get 'archives',     on: :collection
    get 'show_archive', on: :member
    post 'archive',      on: :member
    resource :order do
      get 'checkout'
      get 'confirm'
    end
    resources :designer_replies, path: 'replies', as: 'replies' do
      get 'pick',        on: :member
      put 'update_pick', on: :member
    end
    resource :evaluations
  end

  resources :designer_posts, path: 'posts', as: 'posts'

  #scope '/designers' do
  #  resources :designer_searches, path: 'search' do
  #    put 'accept', on: :member
  #    put 'reject', on: :member
  #    get 'next',   on: :member
  #  end
  #end

  root :to => "site#home"

  mount Jobbr::Engine => "/jobbr"

end
