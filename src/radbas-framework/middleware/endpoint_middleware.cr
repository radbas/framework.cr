class Radbas::EndpointMiddleware
  include Middleware

  def call(context : Context, delegate : ActionLike) : Nil
    unless context.route
      raise MissingRouteException.new("Route data missing, did you add the routing middleware (before)?")
    end
    route = context.route.as(RouteEndpoint)
    route.call(context)
  end
end
