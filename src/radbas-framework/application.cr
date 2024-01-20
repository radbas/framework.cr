class Radbas::Application
  include HTTP::Handler
  include HttpHandler

  def initialize(
    @logger = Log.for("radbas.app")
  )
    @router = Routing::Router(Route).new

    @middleware = [
      RoutingMiddleware.new(@router),
      ActionMiddleware.new,
    ] of MiddlewareLike
    @middleware_insert = -3

    @server_handler = [
      HttpHeadHandler.new,
    ] of HTTP::Handler

    routes.get("/", ->index_action(Context))
  end

  private getter server : HTTP::Server {
    @server_handler << self
    HTTP::Server.new(@server_handler)
  }

  getter routes : RouteCollector {
    RouteCollector.new(@router)
  }

  private def index_action(context : Context) : Nil
    payload = {application: "radbas", version: VERSION, message: "It works!"}
    context.response.content_type = "application/json"
    payload.to_json(context.response.output)
  end

  def add(http_handler : HTTP::Handler) : self
    @server_handler << http_handler
    self
  end

  def add(middleware : MiddlewareLike) : self
    @middleware.insert(@middleware_insert, middleware)
    self
  end

  def add_routing_middleware : RoutingMiddleware
    if @middleware_insert == -3
      @middleware_insert += 1
      return @middleware[@middleware_insert].as(RoutingMiddleware)
    end
    @logger.warn { "routing already added" }
    routing_middleware = RoutingMiddleware.new(@router)
    add routing_middleware
    routing_middleware
  end

  def add_error_middleware(show_details = false) : ErrorMiddleware
    error_handler = CommonErrorHandler.new(show_details)
    error_middleware = ErrorMiddleware.new(error_handler)
    add error_middleware
    error_middleware
  end

  def call(context : HTTP::Server::Context) : Nil
    handle(context)
    @next.as(HTTP::Handler).call(context) if @next
  end

  def handle(context : Context) : Nil
    dispatcher = MiddlewareDispatcher.new(@middleware)
    dispatcher.handle(context)
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
