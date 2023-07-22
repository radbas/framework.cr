class Radbas::Framework::MiddlewareDispatcher < Radbas::Framework::HttpHandler
  @middleware : Iterator(MiddlewareLike | Middleware.class)

  def initialize(
    middleware : Array(MiddlewareLike | Middleware.class),
    @middleware_resolver : Resolver(Middleware),
    @delegate : HttpHandler | Nil = nil
  )
    @middleware = middleware.each
  end

  def handle(context : Context) : Response
    middleware = @middleware.next
    if middleware == Iterator.stop
      return @delegate.as(HttpHandler).handle(context) if @delegate
      raise "end of middleware stack reached"
    end
    unless middleware.is_a?(MiddlewareLike)
      middleware = @middleware_resolver.call(middleware.as(Middleware.class))
    end
    middleware.call(context, self)
  end
end
