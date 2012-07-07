require 'resque/server'
class Authentication
  def initialize(app)
    @app = app
  end

  def call(env)
    user = env['warden'].user
    raise "Cannot access protected resource as: #{user.inspect}" unless user.try(:admin?)
    @app.call(env)
  end
end

Resque::Server.use Authentication