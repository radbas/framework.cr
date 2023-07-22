class Radbas::Framework::RouteMiddleware < Radbas::Framework::Middleware
  def initialize(@middleware_resolver : Resolver(Middleware))
  end

  def call(context : Context, handler : HttpHandler) : Response
    raise "no route in context" unless context.route
    middleware = context.route.as(Route).middleware
    unless middleware.empty?
      dispatcher = MiddlewareDispatcher.new(middleware, @middleware_resolver, handler)
      return dispatcher.handle(context)
    end
    handler.handle(context)
  end
end
