class Radbas::RequestLoggerMiddleware
  include Middleware

  def initialize(
    @logger = Log.for("radbas.app"),
  )
  end

  def call(context : Context, delegate : Next) : Nil
    delegate.call(context)
  ensure
    request = context.request
    response = context.response
    address =
      case remote_address = request.remote_address
      when nil
        "-"
      when Socket::IPAddress
        remote_address.address
      else
        remote_address
      end
    request_line = "\"#{request.method} #{request.resource} #{request.version}\""
    @logger.info {
      "#{address} - #{request_line} #{response.status_code}"
    }
  end
end
