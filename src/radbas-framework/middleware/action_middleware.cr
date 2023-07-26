class Radbas::ActionMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Response
    raise MissingRouteException.new unless context.route
    route = context.route.as(Route)
    middleware = route.middleware
    action = route.action
    unless middleware.empty?
      dispatcher = MiddlewareDispatcher.new(middleware, ->action.call(Context))
      return dispatcher.handle(context)
    end
    action.call(context)
  end
end
