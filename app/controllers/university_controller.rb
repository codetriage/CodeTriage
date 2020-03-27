# frozen_string_literal: true

class UniversityController < ApplicationController
  layout "markdown_page"

  def index
    @page_title = "Open Source Contribution University"
  end

  def show
    case params[:id]
    when "squash"
      @page_title = "Please squash your commits"
      set_title(@page_title)
      set_description("What on earth does squashing commits mean and how do you do it? Find out the what, why, and how of git squashs here.")
      render 'squash'
    when "rebase"
      @page_title = "Please Rebase your commits"
      set_title(@page_title)
      set_description("What on earth does rebasing commits mean and how do you do it? Find out the what, why, and how of git rebases here.")
      render 'rebase'
    when "reproduction_code", "reproduction", "reproduction_case"
      @page_title = "Please Provide Reproduction Code"
      set_title(@page_title)
      set_description("Get answers for your open source bug reports faster by providing a code that reproduces your problem. Find out how.")
      render 'reproduction_code'
    when 'example_app', 'example_apps', 'example-app', 'example-apps'
      @page_title = "Please Provide an Example App"
      set_title(@page_title)
      set_description("Get answers for your open source bug reports faster by providing an example app. Find out how right here.")
      render 'example_app'
    when 'picking_a_repo'
      @page_title = "Picking the Right Repo(s)"
      set_title("Picking the Right Repo(s) to start your Open Source Contribution Journey")
      set_description("One of the most important decisions you'll make when you start contributing is which open source libraries you contribute to. This guide will help you get started")
      render 'picking_a_repo'
    end
  end
end
