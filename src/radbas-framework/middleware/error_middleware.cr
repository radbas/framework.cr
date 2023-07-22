class Radbas::ErrorMiddleware
  include Middleware

  def initialize(@error_handler : ErrorHandler)
  end

  def call(context : Context, handler : HttpHandler) : Response
    handler.handle(context)
  rescue exception
    @error_handler.handle(context, exception)
  end
end
