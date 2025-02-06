class Radbas::SecureHeadersMiddleware
  include Middleware

  def initialize(
    @content_type_options = "nosniff",
    @strict_transport_security = "max-age=31536000; includeSubDomains",
    @frame_options = "SAMEORIGIN",
    @xss_protection = "0",
    @referrer_policy = "no-referrer"
  )
  end

  def call(context : Context, delegate : Next) : Nil
    headers = context.response.headers
    headers["X-Content-Type-Options"] = @content_type_options
    headers["Strict-Transport-Security"] = @strict_transport_security
    headers["X-Frame-Options"] = @frame_options
    headers["X-XSS-Protection"] = @xss_protection
    headers["Referrer-Policy"] = @referrer_policy
    delegate.call(context)
  end
end
