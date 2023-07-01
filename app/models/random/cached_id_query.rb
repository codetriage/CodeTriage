# frozen_string_literal: true

# Provides an actual random result exactly as expected
# but it's cached for a period of time.
#
# Cache keys expire after the set time but
# are unbounded. Take care to not pass in arbitrary data
# from users into the query.
#
# The raw SQL is used for a cache key so take care
# to pass in values in sorted order etc.
#
# The first run of this is VERY expensive on a large
# model and can still cause significant database load
class Random::CachedIdQuery
  private attr_reader :limit, :query, :key, :expires_in

  def initialize(query:, limit:, expires_in:)
    @query = query.order("RANDOM()")
    @key = "random_cached_query:#{@query.to_sql.hash}"
    @expires_in = expires_in
    @limit = limit
  end

  def call
    ids = Rails.cache.fetch(key, expires_in: expires_in) do
      query.select(:id).first(limit).map(&:id)
    end

    query.klass.where(id: ids)
  end
end
