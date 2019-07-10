# frozen_string_literal: true

class ContactRedirectMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request = Rack::Request.new(env)
    if request.path.include?('/contact')
      [301, { 'Location' => '/not-found', 'Content-Type' => 'text/html' }, ['Moved Permanently']]
    else
      @app.call(env)
    end
  end
end
