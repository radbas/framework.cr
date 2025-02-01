class Radbas::EndpointMiddleware
  include Middleware
  include MiddlewareHandler

  # TODO: get return from action
  def call(context : Context, delegate : ActionLike) : Nil
    unless context.route
      raise MissingRouteException.new("Route data missing, did you add the routing middleware?")
    end
    route = context.route.as(Route)
    middleware = route.middleware
    action = route.action
    unless middleware.empty?
      next_handler = ->(ctx : Context, _del : ActionLike) { action.call(ctx) }
      return handle(context, [*middleware, next_handler], 0)
    end
    action.call(context)
  end
end
