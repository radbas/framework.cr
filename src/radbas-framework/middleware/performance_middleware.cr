class Radbas::PerformanceMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Nil
    start_time = Time.monotonic
    start_bytes = GC.stats.total_bytes
    begin
      handler.handle(context)
    ensure
      elapsed = Time.monotonic - start_time
      bytes = GC.stats.total_bytes - start_bytes
      context.response.headers["X-Runtime"] = elapsed.total_milliseconds.round(2).to_s
      context.response.headers["X-Memory"] = bytes.round(2).to_s
    end
  end
end
