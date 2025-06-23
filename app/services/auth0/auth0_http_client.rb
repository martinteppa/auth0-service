require 'net/http'
require 'json'

module Auth0
  class Auth0HttpClient < HttpClientBase
    BASE_URL = "https://#{ENV['AUTH0_DOMAIN']}/api/v2/".freeze
  
    def initialize(token:)
      @token = token
    end
  
    def get(path:)
      super(uri: build_uri(path), headers: default_headers)
    end
  
    def post(path:, body:)
      super(uri: build_uri(path), headers: default_headers, body: body)
    end
  
    def patch(path:, body:)
      super(uri: build_uri(path), headers: default_headers, body: body)
    end
  
    def delete(path:)
      super(uri: build_uri(path), headers: default_headers)
    end
  
    private
  
    def build_uri(path)
      URI.parse("#{BASE_URL}#{path}")
    end
  
    def default_headers
      {
        "Authorization" => "Bearer #{@token}",
        "Content-Type" => "application/json"
      }
    end
  end
  
end
