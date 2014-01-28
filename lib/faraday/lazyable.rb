require "faraday"
require "faraday/lazyable/dummy_response"
require "faraday/lazyable/version"

module Faraday
  class Lazyable
    def initialize(app)
      @app = app
    end

    def call(env)
      DummyResponse.new { @app.call(env) }
    end
  end
end
