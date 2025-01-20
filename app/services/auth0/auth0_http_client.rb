require 'net/http'
require 'json'

module Auth0
  class Auth0HttpClient
    attr_reader :uri, :token

    def initialize(uri:, token:)
      @uri=uri
      @token=token
    end

    def get_request
      request = Net::HTTP::Post.new(uri)
      prepare_request(request, token, body)
      send_request(uri, request)
    end

    def post_request(body:)
      request = Net::HTTP::Post.new(uri)
      prepare_request(request, token, body)
      send_request(uri, request)
    end

    def patch_request(uri:, token:, body:)
      request = Net::HTTP::Patch.new(uri)
      prepare_request(request, token, body)
      send_request(uri, request)
    end

    def delete_request(uri:, token:, body:)
      request = Net::HTTP::Delete.new(uri)
      prepare_request(request, token)
      send_request(uri, request)
    end

    private

    def prepare_request(request, token, body = nil)
      request["Authorization"] = "Bearer #{token}" if token
      request["Content-Type"] = "application/json"
      request.body = body.to_json if body
    end

    def send_request(uri, request)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.request(request)
    end
  end
end
