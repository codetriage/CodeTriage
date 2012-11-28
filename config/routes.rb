require 'resque/server'


Example::Application.routes.draw do
  match "users/sign_in" => redirect('/users/auth/github')
  match "users/sign_up" => redirect('/users/auth/github')

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

  mount_sextant if Rails.env.development?

  resources :repos, except: :show

  get "/:user_name(/:name)/subscribers" => "subscribers#show", as: :repo_subscribers
  get "/:user_name(/:name)" => "repos#show", as: :repo
end
