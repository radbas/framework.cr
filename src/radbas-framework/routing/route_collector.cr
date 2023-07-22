class Radbas::Routing::RouteCollector(A, M)
  def initialize(@router : Router(Route(A, M)))
    @middleware = [] of M
    @path = ""
  end

  def collect(&)
    with self yield
  end

  def set_validator(name : Symbol, validator : Validator) : self
    @router.set_validator(name, validator)
    self
  end

  def group(path : String, middleware = [] of M, &) : self
    current_path = @path
    current_middleware = @middleware
    @path += path
    @middleware = [*@middleware, *middleware]
    with self yield
    @path = current_path
    @middleware = current_middleware
    self
  end

  private def map(method : String, path : String, action : A, middleware : Array(M), name : Symbol?) : self
    route_middleware = [*@middleware, *middleware]
    route = Route(A, M).new(action, route_middleware)
    @router.map([method], @path + path, route, name)
    self
  end

  # define methods
  {% for method in %w(GET POST PUT PATCH DELETE OPTIONS) %}
    def {{method.downcase.id}}(path : String, action : A, middleware = [] of M, name : Symbol? = nil) : self
      map({{method}}, path, action, middleware, name)
    end
  {% end %}
end
