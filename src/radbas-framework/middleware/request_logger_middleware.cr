class Radbas::RequestLoggerMiddleware
  include Middleware

  def initialize(
    @logger = Log.for("radbas.server"),
  )
  end

  def call(context : Context, handler : HttpHandler) : Nil
    handler.handle(context)
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
    datetime = Time.local.to_s("%d/%b/%Y:%H:%M:%S %z")
    @logger.info {
      "#{address} - [#{datetime}] #{request_line} #{response.status_code}"
    }
  end
end
