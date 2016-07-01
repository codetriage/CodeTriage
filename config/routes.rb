# require 'sidekiq/web'

CodeTriage::Application.routes.draw do

  ENV.each do |var, _|
    next unless var.start_with?("ACME_TOKEN_")
    number = var.sub(/ACME_TOKEN_/, '')
    get ".well-known/acme-challenge/#{ ENV["ACME_TOKEN_#{number}"] }" => proc { [200, {}, [ ENV["ACME_KEY_#{number}"] ] ] }
  end

  authenticate :user, lambda { |u| u.admin? } do
    # mount Sidekiq::Web => '/sidekiq'
  end
  resources   :doc_methods

  devise_for :users, skip: [:registration],
    :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" }

  # devise_scope(:user) do
  #   get 'sign_in',  to: 'users/omniauth_callbacks#passthru', as: :new_user_session
  #   get 'sign_out', to: 'users/omniauth_callbacks#passthru', as: :destroy_user_session
  # end

  as :user do
    get   'users/edit' => 'users#edit',   as: :edit_user_registration
    patch 'users'      => 'users#update', as: :user_registration
  end

  root to: "pages#index"

  namespace :users do
    resources :after_signup
  end

  resources   :users, except: [:new, :create, :index]
  get         "/users/unsubscribe/:account_delete_token" => "users#token_delete", as: :token_delete_user
  delete      "/users/unsubscribe/:account_delete_token" => "users#token_destroy"

  resources   :issue_assignments

  get "/issue_assignments/:id/users/:user_id/click",  to: "issue_assignments#click_issue_redirect", as: :issue_click
  get "/doc_methods/:id/users/:user_id/click",        to: "doc_methods#click_method_redirect",      as: :doc_method_click
  get "/doc_methods/:id/users/:user_id/source_click", to: "doc_methods#click_source_redirect",      as: :doc_source_click

  resources   :repo_subscriptions

  if Rails.env.development?
    mount UserMailer::Preview => 'mail_view'
  end

  # format: false gives us rails 3.0 style routes so angular/angular.js is interpreted as
  # user_name: "angular", name: "angular.js" instead of using the "js" as a format
  scope format: false do
    resources :repos, only: %w[index new create]

    scope '*full_name' do
      constraints full_name: /[-_a-zA-Z0-9]+\/[-_\.a-zA-Z0-9]+/ do
        get   '/badges/:badge_type(.:format)', to: 'badges#show',       as: 'badge'

        get   '/',              to: 'repos#show',        as: 'repo'
        patch '/',              to: 'repos#update',      as:  nil
        get   '/edit',          to: 'repos#edit',        as: 'edit_repo'
        get   '/subscribers',   to: 'subscribers#show',  as: 'repo_subscribers'
      end
    end
  end
end
