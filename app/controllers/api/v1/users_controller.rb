class Api::V1::UsersController < ApplicationController
  CREATE_UPDATE_USER_PERMISSION = ["create:users", "update:users"].freeze
  READ_USER_PERMISSION = ["read:users"].freeze

  before_action -> { validate_permissions(CREATE_UPDATE_USER_PERMISSION) }, only: [:create, :update]
  before_action -> { validate_permissions(READ_USER_PERMISSION) }, only: [:get_all, :show]

  # before_action :set_current_user, only: [:show]

  before_action :set_user, only: [:show, :update, :destroy]
  # before_action :set_company

  def create
    begin
      email = user_params[:email].downcase
      auth0_user = Auth0::Auth0Service.new.get_or_create_user(
        email:,
        password: user_params[:password],
        name: user_params[:name]
      )
      user = User.create!(
        name: user_params[:name],
        email: email,
        company_id: params[:company_id],
        status: :active,
        auth0_id: auth0_user["user_id"]
      )
      render json: { message: "User created successfully", user: user }, status: :created
    rescue ActiveRecord::RecordInvalid => e
      render json: { error: "Failed to create user in database", details: e.record.errors.full_messages }, status: :unprocessable_entity
    rescue Auth0::Auth0Service::CustomAuth0Error => e
      render json: { error: "Auth0 Error", details: e.message }, status: :internal_server_error
    rescue StandardError => e
      render json: { error: "Unexpected error", details: e.message }, status: :bad_request
    end
  end

  def index
    filters = { company_id: params[:company_id], not: { status: :deleted } }
    users_data = Pagination.paginate("User", params[:page], params[:per_page] || 10, filters)
    render json: users_data, status: :ok
  end

  def show
    render json: { message: "User retrieved successfully", user: @user }, status: :ok
  end

  def destroy
    p "nothing"
  end

  def update
    if is_invalid_status_update?
      render json: { error: "Invalid status. Only 'active' and 'disabled' are allowed." }, status: :unprocessable_entity
    end
    @user.assign_attributes(user_params)
    unless @user.valid?
      render json: { error: "Invalid parameters", details: @user.errors.full_messages }, status: :unprocessable_entity
    end

    ActiveRecord::Base.transaction do
      begin
        update_user_auth0(user_params, @user.auth0_id)
        @user.save!
        render json: { message: "User updated successfully", user: @user }, status: :ok
      rescue Auth0::Auth0Service::CustomAuth0Error => e
        render json: { error: "Failed to update user in Auth0", details: e.message }, status: :unprocessable_entity
      rescue ActiveRecord::RecordInvalid => e
        render json: { error: "Failed to update user in database", details: e.record.errors.full_messages }, status: :unprocessable_entity
      rescue StandardError => e
        render json: { error: "Unexpected error", details: e.message }, status: :internal_server_error
      end
    end
  end

  private

  def user_params
    allowed_params = [:email, :name, :password, :status, :company_id]
    params.require(:user).permit(allowed_params)
  end

  # def set_company
  #   begin
  #     @company = Company.find_by!(id: params[:company_id])
  #   rescue ActiveRecord::RecordNotFound
  #     render json: { error: "Company not found" }, status: :not_found
  #   end
  # end

  def is_invalid_status_update?
    return false if user_params[:status].nil?
    status_value = user_params[:status].to_s.to_sym
    User.status_keys_without_deleted.include?(status_value) ? false : true
  end

  def set_user
    @user = User.find_by!(id: params[:id], company_id: params[:company_id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'User not found' }, status: :not_found
  end

  def update_user_auth0(user_params, user_auth0_id)
    auth0_body_request = Auth0::Auth0UpdateBody.new(
      name = user_params[:name],
      status = user_params[:status]
    ).body_request
    Auth0::Auth0Service.new.update_user(user_auth0_id, auth0_body_request)
  end
end
