# this extends the default http server context
class HTTP::Server::Context
  @store = {} of String => JSON::Any::Type

  property route : Radbas::Routing::Result(Radbas::Action)?
  property params = {} of String => String
  property files = {} of String => File
  property body : (URI::Params | JSON::Any)?

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
