class Radbas::ActionMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Response
    raise MissingRouteException.new unless context.route
    action = context.route.as(Route).action
    action.call(context)
  end
end
