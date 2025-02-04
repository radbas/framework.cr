class Radbas::ApplicationBuilder < Radbas::RouteCollector
  def initialize(
    @logger = Log.for("radbas.app"),
    @router = Routing::Router(Action).new,
  )
    @middleware = [] of MiddlewareLike
  end

  def add_request_logger_middleware(logger : Log = @logger) : RequestLoggerMiddleware
    logger_middleware = @middleware.find { |entry| entry.is_a?(RequestLoggerMiddleware) }
    unless logger_middleware
      logger_middleware = RequestLoggerMiddleware.new(logger)
      add logger_middleware
    end
    logger_middleware.as(RequestLoggerMiddleware)
  end

  def add_error_handler_middleware(
    error_handler : ErrorHandlerLike = CommonErrorHandler.new(@logger),
  ) : ErrorHandlerMiddleware
    error_middleware = @middleware.find { |entry| entry.is_a?(ErrorHandlerMiddleware) }
    unless error_middleware
      error_middleware = ErrorHandlerMiddleware.new(error_handler)
      add error_middleware
    end
    error_middleware.as(ErrorHandlerMiddleware)
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
    add_error_handler_middleware
    add_routing_middleware
    add EndpointMiddleware.new
    Application.new(@middleware)
  end
end
