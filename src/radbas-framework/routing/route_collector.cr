module Radbas::RouteCollector
  @router : Routing::Router(Route)
  @route_middleware = [] of MiddlewareLike
  @route_path = ""

  def group(path : String = "", middleware = [] of MiddlewareLike, &) : self
    current_path = @route_path
    current_middleware = @middleware
    @route_path = "#{@route_path}#{path}"
    @route_middleware = [*@route_middleware, *middleware]
    with self yield self
    @route_path = current_path
    @route_middleware = current_middleware
    self
  end

  private def map(
    method : String,
    path : String,
    action : ActionLike,
    middleware : Indexable(MiddlewareLike),
    name : Symbol?,
  ) : self
    route_middleware = [*@route_middleware, *middleware]
    route = Route.new(route_middleware, action)
    @router.map([method], "#{@route_path}#{path}", route, name)
    self
  end

  def ws(
    path : String,
    handler : SocketHandlerLike,
    middleware = [] of MiddlewareLike,
    name : Symbol? = nil,
  ) : self
    action = WebSocketAction.new(handler)
    map("WS", path, action, middleware, name)
  end

  def sse(
    path : String,
    handler : StreamHandlerLike,
    middleware = [] of MiddlewareLike,
    name : Symbol? = nil,
  ) : self
    action = ServerSentEvents::Action.new(handler)
    map("GET", path, action, middleware, name)
  end

  {% for method in %w(GET POST PUT PATCH DELETE OPTIONS) %}
    def {{method.downcase.id}}(
      path : String,
      action : ActionLike,
      middleware = [] of MiddlewareLike,
      name : Symbol? = nil
    ) : self
      map({{method}}, path, action, middleware, name)
    end
  {% end %}
end
