class Radbas::RouteEndpoint
  include MiddlewareCollector
  include MiddlewareRunner
  include Action

  def initialize(
    @action : ActionLike,
    @middleware = [] of MiddlewareLike,
  )
  end
end
