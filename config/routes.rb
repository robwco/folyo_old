Folyo2::Application.routes.draw do

  match 'press' => 'site#press'
  match 'learn-more' => 'site#learn_more'
  match 'how-it-works' => 'site#learn_more'
  match 'about' => 'site#about'
  match 'guides' => 'site#guides'
  match 'partners' => 'site#partners'

  resource :guides do
    get 'how_to_pick_a_designer' => redirect('/guides/how_to_pick_a_great_designer')
    get 'how_to_pick_a_great_designer'
    get 'how_to_write_a_good_job_description'
    get 'quora-redesign' => redirect('/guides/quora_redesign')
    get 'quora_redesign'
    get 'quora_redesign_screenshot'
  end

  devise_for :users, :controllers => {:registrations => 'users/registrations'}

  devise_scope :user do
    get "sign_in", :to => "devise/sessions#new"
    get "sign_up", :to => "users/registrations#new"
    match "/sign_up/:initial_role/job" => 'users/registrations#new', :as => 'new_user_with_role', :job => true
    match "/sign_up/:initial_role" => 'users/registrations#new', :as => 'new_user_with_role'
  end

  namespace :admin do
    resources :designers do
      get 'find_coordinates', :on => :collection
      get 'shot_url', :on => :collection
      get 'most_active', :on => :collection
      get 'designer_posts', :on => :collection
      get 'designer_messages', :on => :collection
    end
    resources :clients
  end

  resources :designers do
    resources :messages
    resources :designer_posts, :path => 'posts', :as => 'posts'
  end

  scope '/designers' do
    resources :designer_search, path: 'search' do
      put 'accept', on: :member
      put 'reject', on: :member
      get 'next',   on: :member
    end
  end

  resources :clients

  root :to => "site#home"

end
