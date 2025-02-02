class Radbas::RouteCollector
  include MiddlewareCollector

  def initialize(
    @router : Routing::Router(Action),
    @middleware : Array(MiddlewareLike),
    @route_path : String | Nil,
  )
  end

  def group(path : String, &) : self
    # important - only use current middleware, if route path is given
    middleware = @route_path ? [*@middleware] : [] of MiddlewareLike
    collector = RouteCollector.new(@router, middleware, "#{@route_path}#{path}")
    yield collector
    self
  end

  private def map(
    method : String,
    path : String,
    action : ActionLike,
    name : Symbol?,
  ) : self
    # important - only use current middleware, if route path is given
    middleware = @route_path ? [*@middleware] : [] of MiddlewareLike
    endpoint = Application.new(middleware, action)
    @router.map([method], "#{@route_path}#{path}", endpoint, name)
    self
  end

  def ws(
    path : String,
    handler : SocketHandlerLike,
    name : Symbol? = nil,
  ) : self
    action = WebSocketAction.new(handler)
    map("WS", path, action, name)
  end

  def sse(
    path : String,
    handler : StreamHandlerLike,
    name : Symbol? = nil,
  ) : self
    action = ServerSentEvents::Action.new(handler)
    map("GET", path, action, name)
  end

  {% for method in %w(GET POST PUT PATCH DELETE OPTIONS) %}
    def {{method.downcase.id}}(
      path : String,
      action : ActionLike,
      name : Symbol? = nil
    ) : self
      map({{method}}, path, action, name)
    end
  {% end %}
end
