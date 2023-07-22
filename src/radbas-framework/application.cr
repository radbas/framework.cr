class Radbas::Framework::Application < Radbas::Framework::HttpHandler
  include HTTP::Handler
  @@action_resolver = Resolver(Action).new { |a|
    raise NotImplementedError.new("unable to resolve action #{a}")
  }
  @@middleware_resolver = Resolver(Middleware).new { |m|
    raise NotImplementedError.new("unable to resolve middleware #{m}")
  }

  def initialize(
    @action_resolver : Resolver(Action) = @@action_resolver,
    @middleware_resolver : Resolver(Middleware) = @@middleware_resolver
  )
    @log = Log.for("radbas.app")

    @router = Router.new
    @routing_added = false

    @middleware = [] of MiddlewareLike | Middleware.class
    @added_middleware = [] of MiddlewareLike | Middleware.class
    @fixed_middleware = [
      RouteMiddleware.new(@middleware_resolver),
      ActionMiddleware.new(@action_resolver),
    ]

    @server_handler = [
      HttpHeadHandler.new,
    ] of HTTP::Handler

    routes.get("/", ->hello_world(Context))
  end

  private getter server : HTTP::Server {
    @server_handler << self
    HTTP::Server.new(@server_handler)
  }

  def call(context : HTTP::Server::Context)
    handle(context)
    @next.as(HTTP::Handler).call(context) if @next
  end

  getter routes : RouteCollector {
    RouteCollector.new(@router)
  }

  private def hello_world(context : Context) : Response
    payload = {application: "radbas", version: VERSION, message: "It works!"}
    context.response.content_type = "text/plain"
    context.response.write payload.to_s.to_slice
    context.response
  end

  def add(http_handler : HTTP::Handler) : self
    @server_handler << http_handler
    self
  end

  def add(middleware : MiddlewareLike | Middleware.class) : self
    @added_middleware << middleware
    @middleware = [*@added_middleware, *@fixed_middleware]
    if middleware.is_a?(RoutingMiddleware) || middleware.is_a?(RoutingMiddleware.class)
      @log.warn { "routing already added" } if @routing_added
      @routing_added = true
    end
    self
  end

  def add_routing_middleware : self
    add RoutingMiddleware.new(@router)
    self
  end

  def add_error_middleware(show_details = false) : self
    handler = DefaultErrorHandler.new(show_details)
    add ErrorMiddleware.new(handler)
    self
  end

  def handle(context : Context) : Response
    add_routing_middleware unless @routing_added
    dispatcher = MiddlewareDispatcher.new(@middleware, @middleware_resolver)
    dispatcher.handle(context)
    # unless response == context.response
    #   raise "response mismatch"
    # end
    # response
  end

  def bind(uri : String) : self
    server.bind(uri)
    self
  end

  def bind(host : String, port : Int32) : self
    server.bind_tcp(host, port)
    self
  end

  def listen
    return if server.listening?
    if server.addresses.empty?
      bind = server.bind_tcp("0.0.0.0", 8080)
      @log.warn { "no socket bound, using default #{bind}" }
    end
    server.each_address do |address|
      @log.info { "server listening on #{address}" }
    end
    Signal::INT.trap do
      @log.info { "server shutdown" }
      close
      exit
    end
    server.listen
  end

  def close
    server.close unless server.closed?
  end
end