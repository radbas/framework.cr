class Radbas::CorsMiddleware
  include Middleware

  def call(context : Context, delegate : Next) : Nil
    context.response.headers["Access-Control-Allow-Origin"] = "*"
    delegate.call(context)
  end
end
