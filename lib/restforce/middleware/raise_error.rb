module Restforce
  class Middleware::RaiseError < Faraday::Response::Middleware
    def on_complete(env)
      @env = env
      case env[:status]
      when 404
        raise Faraday::Error::ResourceNotFound, message
      when 401
        raise Restforce::UnauthorizedError, message
      when 413
        raise Faraday::Error::ClientError.new("HTTP 413 - Request Entity Too Large", env[:response])
      when 400...600
        raise Faraday::Error::ClientError.new(message, env[:response])
      end
    end

    def message
      "#{body['errorCode']}: #{body['message'] || body['errorMessage']}"
    end

    def body
      json = JSON.parse(@env[:body])
      if json.is_a?(Array)
        json.first
      else
        json
      end
    end
  end
end
