class Radbas::RoutingMiddleware
  include Middleware

  def initialize(@router : Router)
  end

  def call(context : Context, handler : HttpHandler) : Response
    request_method = context.request.method
    match_result = @router.match(request_method, context.request.path)
    unless match_result.match?
      unless match_result.methods.empty? || request_method == "GET" || request_method == "HEAD"
        raise HttpMethodNotAllowedException.new(context, match_result.methods)
      end
      raise HttpNotFoundException.new(context)
    end
    context.route = match_result.handler.as(Route)
    context.route_params = match_result.params
    handler.handle(context)
  end
end
