module HttpResponses

  def render_bad_request(message)
    render json: { error: message }, status: :bad_request
  end

  

end