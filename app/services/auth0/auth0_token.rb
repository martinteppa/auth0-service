module Auth0
  class Auth0Token
    attr_reader :uri

    def initialize
      @uri = URI.parse("https://#{AUTH0_DOMAIN}/oauth/token")
    end

    def http_client = HttpClientBase.new

    def auth0_token
      response = http_client.post(
        uri:,
        headers: {"Content-Type" => "application/json"},
        body: auth0_token_request_body
      )
      return JSON.parse(response.body)['access_token'] if response.is_a?(Net::HTTPSuccess)
      Rails.logger.error "Auth0 Token Error: #{response.body}"
      raise Auth0Error, "Failed to retrieve Auth0 token: #{response.code} #{response.message}"
    end

    private

    def auth0_token_request_body
      {
        client_id: AUTH0_CLIENT_ID,
        client_secret: AUTH0_CLIENT_SECRET,
        audience: "https://#{AUTH0_DOMAIN}/api/v2/",
        grant_type: 'client_credentials'
      }
    end

  end
end