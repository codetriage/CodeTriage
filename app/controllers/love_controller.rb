class LoveController < ApplicationController
  def index
  end

  def create
    imgur_session = Imgurapi::Session.new(client_id: ENV['IMGUR_CLIENT_ID'], client_secret: ENV['IMGUR_CLIENT_SECRET'])

  end
end
