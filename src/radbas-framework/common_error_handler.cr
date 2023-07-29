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
      status_code = exception.status.code
      if exception.is_a?(HttpMethodNotAllowedException)
        response.headers["Allow"] = exception.methods.join(",")
      end
    end

    payload = {
      status:  status_code,
      message: exception.message,
      details: @show_details ? exception.inspect_with_backtrace.strip.split("\n").map &.strip : nil,
    }

    response.status_code = status_code
    response.content_type = "application/json"
    payload.to_json(response.output)
    response
  end
end
