require 'resque/server'


Example::Application.routes.draw do
  get "users/sign_in" => redirect('/users/auth/github'), via: [:get, :post]
  get "users/sign_up" => redirect('/users/auth/github'), via: [:get, :post]

  devise_for  :users, :controllers => {omniauth_callbacks: "users/omniauth_callbacks",  registrations: "users"}

  resources   :pages
  root        :to => "pages#index"

  namespace :users do
    resources :after_signup#, controller: "after_signup"
  end

  resources   :users

  resources   :issue_assignments
  resources   :repo_subscriptions

  mount Resque::Server.new, :at => "/resque"

  if Rails.env.development?
    mount UserMailer::Preview => 'mail_view'
  end

  # mount_sextant if Rails.env.development?

  resources :repos, :except => :show

  # format: false gives us rails 3.0 style routes so angular/angular.js is interpreted as
  # user_name: "angular", name: "angular.js" instead of using the "js" as a format
  get "/:user_name(/*name)/subscribers" => "subscribers#show", as: :repo_subscribers, format: false
  get "/:user_name(/*name)/edit"        => "repos#edit", format: false
  get "/:user_name(/*name)"             => "repos#show",  format: false
  put "/:user_name(/*name)"             => "repos#update", format: false
end
