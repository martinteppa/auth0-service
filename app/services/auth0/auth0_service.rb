# frozen_string_literal: true

require 'uri'
require 'memery'

module Auth0
  class Auth0Service
    include Memery
    class CustomAuth0Error < StandardError; end

    attr_reader :token

    AUTH0_DOMAIN = ENV['AUTH0_DOMAIN']
    AUTH0_CLIENT_ID = ENV['AUTH0_CLIENT_ID']
    AUTH0_CLIENT_SECRET = ENV['AUTH0_CLIENT_SECRET']
    AUTH0_AUDIENCE = ENV['AUTH0_AUDIENCE']
    BASE_URL = "https://#{AUTH0_DOMAIN}/api/v2/".freeze

    def initialize
      @token = auth0_token
    end

    def get_or_create_user(email:, password:, name:)
      response = http_client.post_request(
        uri: URI.parse("#{BASE_URL}users"),
        token:,
        body: request_body(email, password, name)
      )
      if response.is_a?(Net::HTTPSuccess)
        user = JSON.parse(response.body)
        fetch_role_and_assing_role_to_auth0_user(auth0_user_id: user['user_id'])
        return user
      end
      get_user_by_email(email:)
    end

    def get_user_by_email(email:)
      uri = URI.parse("#{BASE_URL}users-by-email?email=#{encode_param(email)}")
      response = http_client.get_request(uri:, token:)

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "Auth0 Error: #{response.message}"
        raise CustomAuth0Error, "Failed to get Auth0 User: #{response.code} #{response.message}"
      end

      users = JSON.parse(response.body)
      user = users.find { |u| u['email'] == email }

      unless user.present?
        Rails.logger.error 'Auth0 Error: user not found'
        raise CustomAuth0Error, 'Failed to get Auth0 User: not found'
      end

      fetch_role_and_assing_role_to_auth0_user(auth0_user_id: user['user_id'])
      user
    end

    def update_user(user_auth0_id, body = Auth0::Auth0UpdateBody.new.body_request)
      encoded_id = URI.encode_www_form_component(user_auth0_id.to_s)
      response = http_client.patch_request(uri: URI.parse("#{BASE_URL}users/#{encoded_id}"), token:, body:)
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        Rails.logger.error "Auth0 Delete Error: #{response.body}"
        raise CustomAuth0Error, "Failed to update user in Auth0: #{response.code} #{response.message}"
      end
    end

    def delete_user(user_auth0_id:)
      encoded_id = URI.encode_www_form_component(user_auth0_id.to_s)
      uri = URI.parse("#{BASE_URL}users/#{encoded_id}")
      response = http_client.delete_request(uri:, token:)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "Auth0 Delete Error: #{response.body}"
        raise CustomAuth0Error, 'Failed to delete user in Auth0'
      end
      true
    end

    private

    def fetch_role_and_assing_role_to_auth0_user(auth0_user_id:)
      response = http_client.get_request(uri: URI.parse("#{BASE_URL}roles"), token:)

      # TODO: wrappear para que agarre la excepcion
      role = JSON.parse(response.body).find { |r| r['name'] == 'CLIENT' }
      role_id = role['id'] || nil

      body = {
        users: [auth0_user_id]
      }
      http_client.post_request(uri: URI.parse("#{BASE_URL}roles/#{role_id}/users"), token:, body:)
    end

    memoize def http_client = HttpClient.new

    def encode_param(param)
      URI.encode_www_form_component(param)
    end

    def auth0_token
      response = http_client.post_request(
        uri: URI.parse("https://#{AUTH0_DOMAIN}/oauth/token"),
        token: nil,
        body: auth0_token_request_body
      )
      return JSON.parse(response.body)['access_token'] if response.is_a?(Net::HTTPSuccess)

      Rails.logger.error "Auth0 Token Error: #{response.body}"
      raise CustomAuth0Error, "Failed to retrieve Auth0 token: #{response.code} #{response.message}"
    end

    def auth0_token_request_body
      {
        client_id: AUTH0_CLIENT_ID,
        client_secret: AUTH0_CLIENT_SECRET,
        audience: "https://#{AUTH0_DOMAIN}/api/v2/",
        grant_type: 'client_credentials'
      }
    end

    def request_body(email, password, name)
      {
        email: email,
        password: password,
        name: name,
        connection: 'Username-Password-Authentication'
      }
    end
  end
end
