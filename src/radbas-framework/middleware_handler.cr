module Radbas::MiddlewareHandler
  private def handle(context : Context, middleware : Array(MiddlewareLike), position : UInt16) : Nil
    if candidate = middleware[position]?
      next_handler = ->(ctx : Context) { handle(ctx, middleware, position + 1) }
      return candidate.call(context, next_handler)
    end
    raise MiddlewareQueueEndException.new "end of middleware queue reached"
  end
end
