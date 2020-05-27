# frozen_string_literal: true

class UniversitiesController < Frontmatter::PagesController
  layout 'markdown_page'

  def index
    @page_title = "Open Source Contribution University"
  end

  def show
    @page = University.find(params[:id])
    @page_title = @page.title
    set_title @page.title
    set_description @page.description
  end
end
