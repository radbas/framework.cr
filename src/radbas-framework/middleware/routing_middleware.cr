class Radbas::RoutingMiddleware
  include Middleware

  def initialize(@router : Routing::Router(Route))
  end

  def call(context : Context, handler : HttpHandler) : Nil
    request_method = context.request.method
    if request_method == "HEAD"
      request_method = "GET"
    elsif request_method == "GET" && websocket_upgrade_request?(context.request)
      request_method = "WS"
    end
    match_result = @router.match(request_method, context.request.path)
    unless match_result.match?
      unless match_result.methods.empty? || {"GET", "HEAD", "WS"}.includes?(request_method)
        match_result.methods.delete("WS")
        raise HttpMethodNotAllowedException.new(context, match_result.methods)
      end
      raise HttpNotFoundException.new(context)
    end
    context.route = match_result.handler.as(Route)
    context.params = match_result.params
    handler.handle(context)
  end

  private def websocket_upgrade_request?(request : Request) : Bool
    return false unless upgrade = request.headers["Upgrade"]?
    return false unless upgrade.compare("websocket", case_insensitive: true) == 0

    request.headers.includes_word?("Connection", "Upgrade")
  end
end
