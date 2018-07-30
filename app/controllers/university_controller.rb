class UniversityController < ApplicationController
  def show
    case params[:id]
    when 'example_app', 'example_apps', 'example-app', 'example-apps'
      set_title("Please provide an example app")
      set_description("Get answers for your open source bug reports faster by providing an example app. Find out how.")
      render 'example_app'
    end
  end
end
