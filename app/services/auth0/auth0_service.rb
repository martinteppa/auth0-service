# frozen_string_literal: true

require 'uri'
require 'memery'

module Auth0
  class Auth0Service
    attr_reader :token

    def initialize
      @token = auth0_token
    end

    def get_or_create_user(email:, password:, name:)
      response = http_client.post(
        path: "users",
        body: body_create_request(email, password, name)
      )
      if response.is_a?(Net::HTTPSuccess)
        user = JSON.parse(response.body)
        fetch_role_and_assing_role_to_auth0_user(auth0_user_id: user['user_id'])
        return user
      end
      get_user_by_email(email:)
    end

    def get_user_by_email(email:)
      response = http_client.get(path: "users-by-email?email=#{encode_param(email)}")

      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "Auth0 Error: #{response.message}"
        raise Auth0Error, "Failed to get Auth0 User: #{response.code} #{response.message}"
      end

      users = JSON.parse(response.body)
      user = users.find { |u| u['email'] == email }

      unless user.present?
        Rails.logger.error 'Auth0 Error: user not found'
        raise Auth0Error, 'Failed to get Auth0 User: not found'
      end

      fetch_role_and_assing_role_to_auth0_user(auth0_user_id: user['user_id'])
      user
    end

    def update_user(user_auth0_id, body = Auth0::Auth0UpdateBody.new.body_request)
      response = http_client.patch(
        path: "users/#{URI.encode_www_form_component(user_auth0_id.to_s)}",
        body:
      )
      if response.is_a?(Net::HTTPSuccess)
        response
      else
        Rails.logger.error "Auth0 Delete Error: #{response.body}"
        raise Auth0Error, "Failed to update user in Auth0: #{response.code} #{response.message}"
      end
    end

    def delete_user(user_auth0_id:)
      path = "users/#{URI.encode_www_form_component(user_auth0_id.to_s)}"
      response = http_client.delete(path:)
      unless response.is_a?(Net::HTTPSuccess)
        Rails.logger.error "Auth0 Delete Error: #{response.body}"
        raise Auth0Error, 'Failed to delete user in Auth0'
      end
      true
    end

    private

    def fetch_role_and_assing_role_to_auth0_user(auth0_user_id:)
      response = http_client.get(path: "roles")

      # TODO: wrappear para que agarre la excepcion
      role = JSON.parse(response.body).find { |r| r['name'] == 'CLIENT' }
      role_id = role['id'] || nil

      body = {
        users: [auth0_user_id]
      }
      http_client.post(path: "roles/#{role_id}/users", body:)
    end

    def encode_param(param)
      URI.encode_www_form_component(param)
    end

    def http_client
      Auth0HttpClient.new(token:)
    end

    def auth0_token
      Auth0Token.new.auth0_token
    end

    def body_create_request(email, password, name)
      {
        email: email,
        password: password,
        name: name,
        connection: 'Username-Password-Authentication'
      }
    end
  end
end
