class Radbas::Application
  include HTTP::Handler
  include MiddlewareRunner
  include Action

  def initialize(
    @middleware = [] of MiddlewareLike,
    @action = ->call_next(Context),
  )
  end
end
