require 'resque/server'


CodeTriage::Application.routes.draw do
  get "users/sign_in" => redirect('/users/auth/github'), via: [:get, :post]
  get "users/sign_up" => redirect('/users/auth/github'), via: [:get, :post]

  devise_for  :users, controllers: {omniauth_callbacks: "users/omniauth_callbacks",  registrations: "users"}

  root        to: "pages#index"

  namespace :users do
    resources :after_signup
  end

  resources   :users
  get         "/users/unsubscribe/:account_delete_token" => "users#token_delete", as: :token_delete_user
  delete      "/users/unsubscribe/:account_delete_token" => "users#token_destroy"

  resources   :issue_assignments

  get "/issue_assignments/:id/users/:user_id/click", to: "issue_assignments#click_redirect", as: :issue_click

  resources   :repo_subscriptions

  if Rails.env.development?
    mount UserMailer::Preview => 'mail_view'
  end

  mount Resque::Server.new, at: "/codetriage/resque"

  # format: false gives us rails 3.0 style routes so angular/angular.js is interpreted as
  # user_name: "angular", name: "angular.js" instead of using the "js" as a format
  scope format: false do
    resources :repos, only: %w[index new create]

    scope '*full_name' do
      constraints full_name: REPO_PATH_PATTERN do
        get   '/',            to: 'repos#show',        as: 'repo'
        patch '/',            to: 'repos#update',      as:  nil
        get   '/edit',        to: 'repos#edit',        as: 'edit_repo'
        get   '/subscribers', to: 'subscribers#show',  as: 'repo_subscribers'
      end
    end
  end
end
