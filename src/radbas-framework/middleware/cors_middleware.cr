class Radbas::CorsMiddleware
  include Middleware

  def call(context : Context, delegate : ActionLike) : Nil
    context.response.headers["Access-Control-Allow-Origin"] = "*"
    delegate.call(context)
  end
end
