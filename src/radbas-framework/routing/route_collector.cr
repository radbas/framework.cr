class Radbas::RouteCollector
  def initialize(@router : Routing::Router(Route))
    @middleware = [] of MiddlewareLike
    @path = ""
  end

  def set_validator(name : Symbol, validator : Validator) : self
    @router.set_validator(name, validator)
    self
  end

  def group(path : String = "", middleware = [] of MiddlewareLike, &) : self
    current_path = @path
    current_middleware = @middleware
    @path = "#{@path}#{path}"
    @middleware = [*@middleware, *middleware]
    with self yield self
    @path = current_path
    @middleware = current_middleware
    self
  end

  private def map(
    method : String,
    path : String,
    action : ActionLike,
    middleware : Array(MiddlewareLike),
    name : Symbol?,
  ) : self
    route_middleware = [*@middleware, *middleware]
    route = Route.new(action, route_middleware)
    @router.map([method], "#{@path}#{path}", route, name)
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
