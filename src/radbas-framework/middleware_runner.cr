module Radbas::MiddlewareRunner
  include Action

  @middleware : Array(MiddlewareLike)
  @action : ActionLike

  def call(context : Context) : Nil
    run(context, 0)
  end

  private def run(context : Context, position : UInt16) : Nil
    if candidate = @middleware[position]?
      next_handler = ->(ctx : Context) { run(ctx, position + 1) }
      return candidate.call(context, next_handler)
    end
    @action.call(context)
  end
end
