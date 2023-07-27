# this extends the default http server context
class HTTP::Server::Context
  @store = {} of String => JSON::Any::Type

  property route : Radbas::Route?
  property params = {} of String => String
  property files = {} of String => File
  property body : (HTTP::Params | JSON::Any)?

  getter query : HTTP::Params {
    HTTP::Params.parse(@request.query || "")
  }

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
