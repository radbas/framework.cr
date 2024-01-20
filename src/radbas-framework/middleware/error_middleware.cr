class Radbas::ErrorMiddleware
  include Middleware

  def initialize(@error_handler : ErrorHandler)
  end

  def call(context : Context, handler : HttpHandler) : Nil
    handler.handle(context)
  rescue exception
    @error_handler.handle(exception, context)
  end
end
