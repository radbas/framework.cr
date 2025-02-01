class Radbas::Route
  include MiddlewareRunner

  def initialize(
    @middleware : Indexable(MiddlewareLike),
    @endpoint : ActionLike,
  )
  end
end
