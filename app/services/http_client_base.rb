require 'net/http'
require 'json'

class HttpClientBase
  def get(uri:, headers: {})
    request = Net::HTTP::Get.new(uri)
    apply_headers(request, headers)
    send_request(uri, request)
  end

  def post(uri:, headers: {}, body: nil)
    request = Net::HTTP::Post.new(uri)
    apply_headers(request, headers)
    request.body = body.to_json if body
    send_request(uri, request)
  end

  def patch(uri:, headers: {}, body: nil)
    request = Net::HTTP::Patch.new(uri)
    apply_headers(request, headers)
    request.body = body.to_json if body
    send_request(uri, request)
  end

  def delete(uri:, headers: {})
    request = Net::HTTP::Delete.new(uri)
    apply_headers(request, headers)
    send_request(uri, request)
  end

  private

  def apply_headers(request, headers)
    headers.each { |key, value| request[key] = value }
  end

  def send_request(uri, request)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      http.request(request)
    end
  end
end
