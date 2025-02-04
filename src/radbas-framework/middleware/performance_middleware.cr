class Radbas::PerformanceMiddleware
  include Middleware

  def initialize(
    @logger = Log.for("radbas.app"),
  )
  end

  def call(context : Context, delegate : Next) : Nil
    start_time = Time.monotonic
    start_bytes = GC.stats.total_bytes
    begin
      delegate.call(context)
    ensure
      elapsed = Time.monotonic - start_time
      bytes = GC.stats.total_bytes - start_bytes
      @logger.info {
        "Time: #{elapsed.total_milliseconds.round(2)} ms | Memory: #{bytes.round(2)} bytes"
      }
    end
  end
end
