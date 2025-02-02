module Radbas::MiddlewareCollector
  @middleware : Array(MiddlewareLike)

  def add(http_handler : HTTP::Handler) : self
    add ->(ctx : Context, delegate : Next) do
      http_handler.next = delegate
      http_handler.call(ctx)
    end
    self
  end

  def add(middleware : MiddlewareLike) : self
    @middleware << middleware
    self
  end
end
