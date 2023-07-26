class Radbas::TrailingSlashMiddleware
  include Middleware

  def initialize(@trailing_slash = false)
  end

  def call(context : Context, handler : HttpHandler) : Response
    path = context.request.path
    unless path == "/"
      new_path = "#{path.rstrip("/")}#{(@trailing_slash ? "/" : "")}"
      unless new_path == path
        context.response.redirect(new_path, HTTP::Status::MOVED_PERMANENTLY)
        return context.response
      end
    end
    handler.handle(context)
  end
end
