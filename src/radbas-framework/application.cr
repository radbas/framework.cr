class Radbas::Application < Radbas::RouteCollector
  include HTTP::Handler
  include MiddlewareRunner
  include Action

  def initialize(
    @router = Routing::Router(RouteEndpoint).new,
    @logger = Log.for("radbas.app"),
  )
    @middleware = [] of MiddlewareLike
    @action = ->call_next(Context)
  end

  private getter server : HTTP::Server {
    HTTP::Server.new([HttpHeadHandler.new, self])
  }

  def add_logging_middleware : LoggingMiddleware
    logging_middleware = LoggingMiddleware.new(@logger)
    add logging_middleware
    logging_middleware
  end

  def add_error_middleware(show_details = false) : ErrorMiddleware
    error_handler = CommonErrorHandler.new(show_details, @logger)
    error_middleware = ErrorMiddleware.new(error_handler)
    add error_middleware
    error_middleware
  end

  def add_routing_middleware : RoutingMiddleware
    routing_middleware = RoutingMiddleware.new(@router)
    add routing_middleware
    routing_middleware
  end

  def add_endpoint_middleware : EndpointMiddleware
    endpoint_middleware = EndpointMiddleware.new
    add endpoint_middleware
    endpoint_middleware
  end

  def bind(uri : String) : self
    server.bind(uri)
    self
  end

  def bind(host : String, port : Int32, reuse_port = false) : self
    server.bind_tcp(host, port, reuse_port)
    self
  end

  def listen : Nil
    return if server.listening?
    if server.addresses.empty?
      bind = server.bind_tcp("0.0.0.0", 8080)
      @logger.warn { "no socket bound, using default #{bind}" }
    end
    server.each_address do |address|
      @logger.info { "server listening on #{address}" }
    end
    Signal::INT.trap &->shutdown(Signal)
    Signal::TERM.trap &->shutdown(Signal)
    server.listen
  end

  private def shutdown(signal : Signal) : Nil
    @logger.info { "server shutdown" }
    close
    exit
  end

  def close : Nil
    server.close unless server.closed?
  end
end
