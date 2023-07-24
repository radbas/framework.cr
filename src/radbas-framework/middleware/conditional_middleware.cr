class Radbas::ConditionalMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Response
    raise MissingRouteException.new unless context.route
    middleware = context.route.as(Route).middleware
    unless middleware.empty?
      dispatcher = MiddlewareDispatcher.new(middleware, handler)
      return dispatcher.handle(context)
    end
    handler.handle(context)
  end
end
