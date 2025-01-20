class PrivateController < ApplicationController
  PERMISSIONS = ["create:users"].freeze

  before_action :authorize
  before_action -> { validate_permissions(PERMISSIONS) }, only: [:private_scoped]

  def private
    render json: { message: 'Hello from a private endpoint! You need to be authenticated to see this.' }
  end

  def private_scoped
    render json: { message: 'Hello from a private endpoint! You need to be authenticated and have a scope of read:messages to see this.' }
  end
end