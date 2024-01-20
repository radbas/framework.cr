module Radbas::ServerSentEvents
  record Message,
    data : Iterable(String),
    event : String? = nil,
    id : String? = nil,
    retry : Int64? = nil do
    def to_s(io : IO)
      io << "event: #{event}\n" if event
      io << "id: #{id}\n" if id
      io << "retry: #{retry}\n" if retry
      data.each do |chunk|
        io << "data: #{chunk}\n"
      end
      io << '\n'
    end
  end

  class Stream
    getter? closed = false
    getter idle_time = 0

    def initialize(@io : IO)
    end

    def on_close(&@on_close : ->)
    end

    def send(message : Message) : Nil
      raise "cannot send to closed sse stream" if closed?
      begin
        message.to_s(@io)
        @io.flush
        @idle_time = 0
      rescue
        close
        @on_close.try &.call
      end
    end

    def send(
      data : Iterable(String),
      event : String? = nil,
      id : String? = nil,
      retry : Int64? = nil
    ) : Nil
      send Message.new(data, event, id, retry)
    end

    def close : Nil
      return if closed?
      @closed = true
    end

    def start : Nil
      @idle_time = 0
      until closed?
        sleep 1
        if (@idle_time += 1) >= 60 * 30 # 30 minutes timeout
          close
          @on_close.try &.call
        end
      end
    end
  end

  class Action
    include Radbas::Action

    def initialize(@stream_handler : StreamHandlerLike)
    end

    def call(context : Context) : Nil
      response = context.response
      response.content_type = "text/event-stream"
      response.headers["Cache-Control"] = "no-cache"
      response.upgrade do |io|
        stream = Stream.new(io)
        @stream_handler.call(stream, context)
        stream.start
      end
    end
  end
end
