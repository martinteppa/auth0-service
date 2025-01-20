require 'net/http'
require 'json'

class HttpClient

  def get_request(uri:, token:)
    request = Net::HTTP::Get.new(uri)
    if token
      request["Authorization"] = "Bearer #{token}"
    end
    request["Content-Type"] = "application/json"
    response = send_request(uri, request)
    return response
  end

  def post_request(uri:, token:, body:)
    request = Net::HTTP::Post.new(uri)
    if token
      request["Authorization"] = "Bearer #{token}"
    end
    request["Content-Type"] = "application/json"
    request.body = body.to_json
    response = send_request(uri, request)
    return response
  end

  def patch_request(uri:, token:, body:)
    request = Net::HTTP::Patch.new(uri)
    if token
      request["Authorization"] = "Bearer #{token}"
    end
    request["Content-Type"] = "application/json"
    request.body = body.to_json
    response = send_request(uri, request)
    return response
  end

  def delete_request(uri:, token:, body:)
    request = Net::HTTP::Delete.new(uri)
    if token
      request["Authorization"] = "Bearer #{token}"
    end
    request["Content-Type"] = "application/json"
    request.body = body.to_json
    response = send_request(uri, request)
    return response
  end

  private

  def send_request(uri, request)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.request(request)
  end
end
