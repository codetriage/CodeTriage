class UniversityController < ApplicationController
  layout "markdown_page"

  def show
    case params[:id]
    when 'example_app', 'example_apps', 'example-app', 'example-apps'
      set_title("Please Provide an Example App")
      set_description("Get answers for your open source bug reports faster by providing an example app. Find out how.")
      @page_title = "Please Provide an Example App"
      render 'example_app'
    when 'picking_a_repo'
      set_title("Picking the Right Repo(s) to start your Open Source Contribution Journey")
      set_description("One of the most important decisions you'll make when you start contributing is which open source libraries you contribute to")
      @page_title = "Picking the Right Repo(s)"
      render 'picking_a_repo'
    end
  end
end
