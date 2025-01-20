class Api::V1::CompaniesController < ApplicationController

  CREATE_UPDATE_READ_COMPANY_PERMISSION = ["create:company", "update:company", "read:company"].freeze

  before_action -> { validate_permissions(CREATE_UPDATE_COMPANY_PERMISSION) }, only: [:create, :update]
  before_action -> { validate_permissions(READ_COMPANY_PERMISSION) }, only: [:get_all, :show]

  before_action :set_company, only: [:show, :update]


  def index
    companies_data = Pagination.paginate("Company", params[:page], params[:per_page] || 10)
    render json: companies_data, status: :ok
  end

  # GET /companies/:id
  def show
    render json: { message: "Company retrieved successfully", company: @company }, status: :ok
  end

  # POST /companies
  def create
    ## TODO: CREAR LA BASE DE DATOS CADA VEZ QUE SE CREE UNA COMPANIA
    @company = Company.new(company_params)

    if @company.save
      render json: { message: "Company created successfully", company: @company }, status: :created
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /companies/:id
  def update
    ## TODO: UPDATEAR BASE DE DATOS?? O NO PERMITIR CAMBIO EN EL NOMBRE DE LA BASE DE DATOS
    if @company.update(company_params)
      render json: { message: "Company updated successfully", company: @company }, status: :ok
    else
      render json: @company.errors, status: :unprocessable_entity
    end
  end

  # DELETE /companies/:id
  #def destroy
  #  @company.destroy
  #  head :no_content
  #end

  private

  def set_company
    @company = Company.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Company not found" }, status: :not_found
  end

  def company_params
    params.require(:company).permit(:name, :database_name)
  end
end
