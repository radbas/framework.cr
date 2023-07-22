# this extends the default http server context
class HTTP::Server::Context
  alias StoreTypes = String | Int32 | Int64 | Float64 | Bool

  property route : Radbas::Framework::Route?
  property args : Radbas::Framework::ActionArgs = {} of String => String

  @store = {} of String => StoreTypes

  def []=(key, value)
    @store[key] = value
  end

  def [](key)
    @store[key]
  end

  def []?(key)
    @store[key]?
  end
end
