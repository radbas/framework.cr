module Radbas::MiddlewareRunner
  include Action

  @middleware : Array(MiddlewareLike)
  @action : ActionLike

  def call(context : Context) : Nil
    position = -1
    delegate = uninitialized Context -> Nil
    delegate = ->(ctx : Context) {
      if handler = @middleware[position += 1]?
        return handler.call(ctx, delegate)
      end
      @action.call(ctx)
    }
    delegate.call(context)
  end
end
