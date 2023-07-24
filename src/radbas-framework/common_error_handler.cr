class Radbas::CommonErrorHandler
  include ErrorHandler

  def initialize(
    @show_details = false,
    @logger = Log.for("radbas.app")
  )
  end

  def handle(context : Context, exception : Exception) : Response
    response = context.response

    status_code : Int32 = HTTP::Status::INTERNAL_SERVER_ERROR.code
    if context.request.method == "OPTIONS"
      status_code = HTTP::Status::OK.code
    elsif exception.is_a?(HttpException)
      status_code = exception.code
      if exception.is_a?(HttpMethodNotAllowedException)
        response.headers["Allow"] = exception.methods.join(",")
      end
    end

    if @show_details
      details = exception.inspect_with_backtrace.strip.split("\n").map &.strip
    else
      details = [] of String
    end

    payload = {
      status:  status_code,
      message: exception.message.to_s,
      details: details,
    }

    response.status_code = status_code.to_i
    response.content_type = "application/json"
    payload.to_json(response.output)
    response
  end
end
