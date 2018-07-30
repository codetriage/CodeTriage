class UniversityController < ApplicationController
  layout "markdown_page"

  def show
    case params[:id]
    when 'example_app', 'example_apps', 'example-app', 'example-apps'
      set_title("Please Provide an Example App")
      set_description("Get answers for your open source bug reports faster by providing an example app. Find out how.")
      @page_title = "Plsease Provide an Example App"
      render 'example_app'
    end
  end
end
