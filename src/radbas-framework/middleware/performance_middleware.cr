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
        "time: #{elapsed.total_milliseconds.round(2)} ms | memory: #{(bytes / 1024 / 1024).round(2)} mb"
      }
    end
  end
end
