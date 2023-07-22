class Radbas::MiddlewareDispatcher
  include HttpHandler

  @middleware : Iterator(MiddlewareLike)

  def initialize(
    middleware : Array(MiddlewareLike),
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
    middleware.as(MiddlewareLike).call(context, self)
  end
end
