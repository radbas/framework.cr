class Radbas::ErrorHandlerMiddleware
  include Middleware

  def initialize(@error_handler : ErrorHandlerLike)
  end

  def call(context : Context, delegate : Next) : Nil
    delegate.call(context)
  rescue exception
    @error_handler.call(context, exception)
  end
end
