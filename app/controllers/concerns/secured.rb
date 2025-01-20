# frozen_string_literal: true

module Secured
  extend ActiveSupport::Concern

  REQUIRES_AUTHENTICATION = { message: 'Requires authentication' }.freeze
  BAD_CREDENTIALS = {
    message: 'Bad credentials'
  }.freeze
  MALFORMED_AUTHORIZATION_HEADER = {
    error: 'invalid_request',
    error_description: 'Authorization header value must follow this format: Bearer access-token',
    message: 'Bad credentials'
  }.freeze
  INSUFFICIENT_PERMISSIONS = {
    error: 'insufficient_permissions',
    error_description: 'The access token does not contain the required permissions',
    message: 'Permission denied'
  }.freeze

  def authorize
    token = token_from_request
    return if performed?

    validation_response = Auth0Client.validate_token(token)
    @decoded_token = validation_response.decoded_token
    unless @decoded_token.is_a?(Auth0Client::Token)
      render json: { error: "Invalid token" }, status: :unauthorized
      return
    end

    @decoded_token.token.first.with_indifferent_access[:sub]
    @user_permissions = @decoded_token.token.first.with_indifferent_access[:permissions]
    return unless (error = validation_response.error)

    render json: { message: error.message }, status: error.status
  end

  def set_current_user
    return unless @decoded_token
    @current_user_id ||= @decoded_token.token.first&.with_indifferent_access&.dig(:sub)
    return render json: { error: "Invalid token structure" }, status: :unauthorized unless @current_user_id
    @current_user ||= User.find_by(auth0_id: @current_user_id)
    return render json: { error: "User logged in not found" }, status: :unauthorized unless @current_user
  end
  

  def validate_permissions(permissions)
    if !@decoded_token.respond_to?(:validate_permission_token) || !@decoded_token.validate_permission_token(permissions)
      render json: { error: "Forbidden - Insufficient Permissions" }, status: :forbidden
    end
  end

  private

  def token_from_request
    authorization_header_elements = request.headers['Authorization']&.split

    render json: REQUIRES_AUTHENTICATION, status: :unauthorized and return unless authorization_header_elements

    unless authorization_header_elements.length == 2
      render json: MALFORMED_AUTHORIZATION_HEADER,
             status: :unauthorized and return
    end

    scheme, token = authorization_header_elements

    render json: BAD_CREDENTIALS, status: :unauthorized and return unless scheme.downcase == 'bearer'

    token
  end
end