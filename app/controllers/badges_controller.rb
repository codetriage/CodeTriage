class BadgesController < ApplicationController
  def show
    repo = Repo.where(full_name: permitted[:full_name])
               .select(:subscribers_count, :issues_count, :updated_at)
               .first
    raise ActionController::RoutingError.new('Not Found') if repo.blank?

    case permitted[:badge_type]
    when "users"
      count = repo.subscribers_count
      svg   = make_shield(name: "code helpers", count: count, color_b: repo.color)
    else
      raise ActionController::RoutingError.new('Not Found')
    end

    # Set Cache-Control header
    expires_in 1.hour, public: true

    # Firefox requires an `Expires` header
    # https://stackoverflow.com/questions/10518493/why-does-firefox-not-appear-to-be-caching-images
    request.headers["Expires"] = 1.hour.from_now

    # When an ETag header is sent, the Cache-Control header is not respected
    # https://stackoverflow.com/questions/18557251/why-does-browser-still-sends-request-for-cache-control-public-with-max-age
    #
    # The `fresh_when` method sets the 'Last-Modified' which forces ETag
    # to not be added by Rack::Etag
    # https://github.com/rack/rack/blob/ab008307cbb805585449145966989d5274fbe1e4/lib/rack/etag.rb#L59
    # fresh_when last_modified: repo.updated_at, public: true
    #
    # That didn't work because setting 'Last-Modified' header forces
    # some requests to check that the end point is not "stale", this in turn
    # causes a double render error because a "HEAD" request already has
    # an empty body. Also this second "stale" request would still result
    # in a DB query which we want to avoid.
    #
    # We can instead bypass the Rack::ETag behavior by using the 203 response
    # https://github.com/rack/rack/blob/master/lib/rack/etag.rb#L50
    #
    # But a 203 makes GitHub's CDN service choke :(
    respond_to do |format|
      format.svg { render plain: svg, status: 200 }
    end
  end

  private

  def escapeXml(var)
    var
  end

  def width_of(string)
    pdf = Prawn::Document.new
    pdf.font("Helvetica-Bold")
    pdf.font_size = 12.2
    pdf.width_of(string.to_s)
  end

  def make_shield(name:, count:, color_a: "555", color_b: "4c1", logo_width: 0, logo_padding: 0)
    name_width  = (width_of(name) + 10).to_f
    count_width = (width_of(count) + 10).to_f
    total_width = name_width + count_width
    svg = <<~EOS
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="#{total_width}" height="20">
        <linearGradient id="smooth" x2="0" y2="100%">
          <stop offset="0" stop-color="#bbb" stop-opacity=".1"/>
          <stop offset="1" stop-opacity=".1"/>
        </linearGradient>

        <clipPath id="round">
          <rect width="#{total_width}" height="20" rx="3" fill="#fff"/>
        </clipPath>

        <g clip-path="url(#round)">
          <rect width="#{name_width}" height="20" fill="##{escapeXml(color_a)}"/>
          <rect x="#{name_width}" width="#{count_width}" height="20" fill="##{escapeXml(color_b)}"/>
          <rect width="#{total_width}" height="20" fill="url(#smooth)"/>
        </g>

        <g fill="#fff" text-anchor="middle" font-family="DejaVu Sans,Verdana,Geneva,sans-serif" font-size="110">
          <text x="#{(((name_width + logo_width + logo_padding) / 2) + 1) * 10}" y2="150" fill="#010101" fill-opacity=".3" transform="scale(0.1)" textLength="#{(name_width - (10 + logo_width + logo_padding)) * 10}" lengthAdjust="spacing">#{escapeXml(name)}</text>
          <text x="#{(((name_width + logo_width + logo_padding) / 2) + 1) * 10}" y="140" transform="scale(0.1)" textLength="#{(name_width - (10 + logo_width + logo_padding)) * 10}" lengthAdjust="spacing">#{escapeXml(name)}</text>
          <text x="#{(name_width + count_width / 2 - 1) * 10}" y="150" fill="#010101" fill-opacity=".3" transform="scale(0.1)" textLength="#{(count_width - 10) * 10}" lengthAdjust="spacing">#{escapeXml(count)}</text>
          <text x="#{(name_width + count_width / 2 - 1) * 10}" y="140" transform="scale(0.1)" textLength="#{(count_width - 10) * 10}" lengthAdjust="spacing">#{escapeXml(count)}</text>
        </g>
      </svg>
    EOS
    return svg
  end

  def permitted
    params.permit(:full_name, :badge_type)
  end

  def render_503
    head :service_unavailable
  end
end
