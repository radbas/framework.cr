class Radbas::CorsMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Nil
    context.response.headers["Access-Control-Allow-Origin"] = "*"
    handler.handle(context)
  end
end
