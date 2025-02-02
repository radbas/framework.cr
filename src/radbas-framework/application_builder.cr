class Radbas::ApplicationBuilder < Radbas::RouteCollector
  def initialize(
    @logger = Log.for("radbas.app"),
    @router = Routing::Router(Action).new,
  )
    @middleware = [] of MiddlewareLike
  end

  def add_logging_middleware : LoggingMiddleware
    logging_middleware = LoggingMiddleware.new(@logger)
    add logging_middleware
    logging_middleware
  end

  def add_error_middleware(show_details = false) : ErrorMiddleware
    error_middleware = @middleware.find { |entry| entry.is_a?(ErrorMiddleware) }
    unless error_middleware
      error_handler = CommonErrorHandler.new(show_details, @logger)
      error_middleware = ErrorMiddleware.new(error_handler)
      add error_middleware
    end
    error_middleware.as(ErrorMiddleware)
  end

  def add_routing_middleware : RoutingMiddleware
    routing_middleware = @middleware.find { |entry| entry.is_a?(RoutingMiddleware) }
    unless routing_middleware
      routing_middleware = RoutingMiddleware.new(@router)
      add routing_middleware
    end
    routing_middleware.as(RoutingMiddleware)
  end

  def build : Application
    add_error_middleware
    add_routing_middleware
    add EndpointMiddleware.new
    Application.new(@middleware)
  end
end
