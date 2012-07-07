require 'resque/server'
class Authentication
  def initialize(app)
    @app = app
  end

  def call(env)
    raise 'protected resource' unless env['warden'].user && env['warden'].user.admin?
    @app.call(env)
  end
end

Resque::Server.use Authentication