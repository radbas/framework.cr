class Radbas::Application
  include HTTP::Handler
  include MiddlewareHandler

  def initialize(
    @logger = Log.for("radbas.app"),
  )
    @router = Routing::Router(Route).new
    @middleware = [] of MiddlewareLike
  end

  private getter server : HTTP::Server {
    HTTP::Server.new([HttpHeadHandler.new, self])
  }

  getter routes : RouteCollector {
    RouteCollector.new(@router)
  }

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

  private def next_handler(context : Context, delegate : ActionLike)
    call_next(context)
  end

  def call(context : HTTP::Server::Context) : Nil
    # TODO: cache middleware stack
    middleware = [*@middleware, ->next_handler(Context, ActionLike)]
    handle(context, middleware, 0)
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
