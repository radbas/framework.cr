class Radbas::SecureHeadersMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Response
    headers = context.response.headers
    headers["X-Content-Type-Options"] = "nosniff"
    headers["Strict-Transport-Security"] = "max-age=31536000; includeSubDomains"
    headers["X-Frame-Options"] = "SAMEORIGIN"
    headers["X-XSS-Protection"] = "0"
    headers["Referrer-Policy"] = "no-referrer"
    handler.handle(context)
  end
end
