# this extends the default http server context
class HTTP::Server::Context
  @store = JSON::Any.new({} of String => JSON::Any)

  property route : Radbas::Route?
  property route_params = {} of String => String
  property files = {} of String => File
  property parsed_body : (HTTP::Params | JSON::Any)?

  getter query_params : HTTP::Params {
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
