class Radbas::EndpointMiddleware
  include Middleware

  def call(context : Context, delegate : Next) : Nil
    unless route = context.route
      return delegate.call(context)
    end
    unless route.match?
      unless route.methods.empty? || {"GET", "HEAD", "WS"}.includes?(context.request.method)
        allowed_methods = route.methods.dup
        allowed_methods.delete("WS")
        raise HttpMethodNotAllowedException.new(context, allowed_methods)
      end
      raise HttpNotFoundException.new(context)
    end
    route.handler.as(Action).call(context)
  end
end
