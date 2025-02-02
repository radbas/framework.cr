class Radbas::RoutingMiddleware
  include Middleware

  def initialize(@router : Routing::Router(Action))
  end

  def call(context : Context, delegate : Next) : Nil
    request_method = context.request.method
    if request_method == "HEAD"
      request_method = "GET"
    elsif request_method == "GET" && websocket_upgrade_request?(context.request)
      request_method = "WS"
    end
    result = @router.match(request_method, context.request.path)
    context.params = result.params
    context.route = result
    delegate.call(context)
  end

  private def websocket_upgrade_request?(request : Request) : Bool
    return false unless upgrade = request.headers["Upgrade"]?
    return false unless upgrade.compare("websocket", case_insensitive: true) == 0

    request.headers.includes_word?("Connection", "Upgrade")
  end
end
