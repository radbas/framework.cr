class Radbas::ApplicationBuilder
  @logger = Log.for("radbas.app")
  @router = Routing::Router(Route).new

  def initialize()
    @middleware = [] of MiddlewareLike
  end

  def use(http_handler : HTTP::Handler) : self
    use ->(ctx : Context, delegate : ActionLike) do
      http_handler.next = delegate
      http_handler.call(ctx)
    end
    self
  end

  def use(middleware : MiddlewareLike) : self
    @middleware << middleware
    self
  end

  def use_logging_middleware : LoggingMiddleware
    logging_middleware = LoggingMiddleware.new(@logger)
    use logging_middleware
    logging_middleware
  end

  def use_error_middleware(show_details = false) : ErrorMiddleware
    error_handler = CommonErrorHandler.new(show_details, @logger)
    error_middleware = ErrorMiddleware.new(error_handler)
    use error_middleware
    error_middleware
  end

  def use_routing_middleware : RoutingMiddleware
    routing_middleware = RoutingMiddleware.new(@router)
    use routing_middleware
    routing_middleware
  end

  def use_endpoint_middleware : EndpointMiddleware
    endpoint_middleware = EndpointMiddleware.new
    use endpoint_middleware
    endpoint_middleware
  end

  def build : Application
    Application.new(@middleware, @router, @logger)
  end
end
