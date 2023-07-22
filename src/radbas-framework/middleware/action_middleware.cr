class Radbas::Framework::ActionMiddleware < Radbas::Framework::Middleware
  def initialize(@action_resolver : Resolver(Action))
  end

  def call(context : Context, handler : HttpHandler) : Response
    raise "no route in context" unless context.route
    action = context.route.as(Route).action
    unless action.is_a?(ActionLike)
      action = @action_resolver.call(action)
    end
    action.call(context)
  end
end
