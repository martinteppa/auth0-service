class ApplicationController < ActionController::Base
  #include HttpResponses
  include Secured

  before_action :authorize
  protect_from_forgery with: :null_session, if: -> { request.format.json? }
end
