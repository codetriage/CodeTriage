# frozen_string_literal: true

require 'sidekiq/web'

CodeTriage::Application.routes.draw do
  sitemap_url = File.join("https://#{ENV['BUCKETEER_BUCKET_NAME']}.s3.amazonaws.com/", "sitemaps", "sitemap.xml.gz")
  get 'sitemap.xml.gz', to: redirect(sitemap_url)

  authenticate :user, lambda { |u| u.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  resources :doc_methods, only: [:show]

  resources :university, only: [:show, :index]
  get 'example_app' => 'university#show', id: 'example_app'
  get 'reproduction' => 'university#show', id: 'reproduction'
  get 'repro' => 'university#show', id: 'reproduction'
  get 'squash' => 'university#show', id: 'squash'
  get 'rebase' => 'university#show', id: 'rebase'

  devise_for :users, skip: [:registration],
                     :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  as :user do
    get   'users/edit' => 'users#edit',   as: :edit_user_registration
    patch 'users'      => 'users#update', as: :user_registration
  end

  root to: "pages#index"
  resources :topics, only: [:show]

  get 'what'    => "pages#what"
  get 'privacy' => "pages#privacy"
  get 'support' => 'pages#support'

  namespace :users do
    resources :after_signup, only: [:show, :update]
  end

  resources   :users, only: [:show, :edit, :update, :destroy]
  get         "/users/unsubscribe/:account_delete_token" => "users#token_delete", as: :token_delete_user
  delete      "/users/unsubscribe/:account_delete_token" => "users#token_destroy"

  resources   :issue_assignments, only: [:create]

  get "/issue_assignments/:id/users/:user_id/click",  to: "issue_assignments#click_issue_redirect", as: :issue_click
  get "/doc_methods/:id/users/:user_id/click",        to: "doc_methods#click_method_redirect",      as: :doc_method_click
  get "/doc_methods/:id/users/:user_id/source_click", to: "doc_methods#click_source_redirect",      as: :doc_source_click

  resources :repo_subscriptions, only: [:create, :destroy, :update]

  get 'mail_view', to: redirect('rails/mailers')

  # format: false gives us rails 3.0 style routes so angular/angular.js is interpreted as
  # user_name: "angular", name: "angular.js" instead of using the "js" as a format
  scope format: false do
    resources :repos, only: [:index, :new, :create] do
      collection do
        get :list
      end
    end

    scope '*full_name' do
      constraints full_name: /[-_a-zA-Z0-9]+\/[-_\.a-zA-Z0-9]+/ do
        get   '/badges/:badge_type(.:format)', to: 'badges#show', as: 'badge'
        get   'info(.:format)',           to: 'api_info#show'

        get   '/',              to: 'repos#show',        as: 'repo'
        patch '/',              to: 'repos#update',      as: nil
        get   '/edit',          to: 'repos#edit',        as: 'edit_repo'
        get   '/subscribers',   to: 'subscribers#show',  as: 'repo_subscribers'
      end
    end
  end
end
