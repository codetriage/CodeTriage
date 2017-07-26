class BadgesController < ApplicationController
  def show
    repo = Repo.where(full_name: permitted[:full_name]).first
    raise ActionController::RoutingError.new('Not Found') if repo.blank?

    case permitted[:badge_type]
    when "users"
      count = repo.users.count.to_s
      key   = repo.cache_key + "/badges/".freeze + count

      unless svg = Rails.cache.read(key)
        result = Excon.get(
          "https://img.shields.io/badge/code%20helpers-#{count}-#{repo.color}.svg",
          read_timeout: 3,
          idempotent: true
        )
        raise ActionController::RoutingError.new('Not Found') unless result.status == 200
        svg = result.body
        Rails.cache.write(key, result.body, expires_in: 1.day)
      end
    else
      raise ActionController::RoutingError.new('Not Found')
    end

    response.headers["Cache-Control"] = "public max-age=3600" # one hour
    respond_to do |format|
      format.svg { render plain: svg }
    end
  end


  def permitted
    params.permit(:full_name, :badge_type)
  end
end
