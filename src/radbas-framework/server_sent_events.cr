module Radbas::ServerSentEvents
  record Message,
    data : String,
    event : String? = nil,
    id : String? = nil,
    retry : Int64? = nil do
    def to_s(io : IO)
      io << "event: #{event}\n" if event
      io << "data: #{data}\n"
      io << "id: #{id}\n" if id
      io << "retry: #{retry}\n" if retry
      io << "\n"
    end
  end

  class Stream
    getter? closed = false

    def initialize(@io : IO)
    end

    def send(message : Message) : Bool
      return false if closed?
      begin
        message.to_s(@io)
        @io.flush
        return true
      rescue
        close
      end
      false
    end

    def send(data : String, event : String? = nil, id : String? = nil, retry : Int64? = nil) : Bool
      send Message.new(data, event, id, retry)
    end

    def close : Nil
      return if closed?
      @closed = true
    end

    def start : Nil
      loop do
        # TODO: timeout
        break if closed?
        sleep 1
      end
    end
  end

  class Action
    include Radbas::Action

    def initialize(@stream_handler : StreamHandlerLike)
    end

    def call(context : Context) : Response
      response = context.response
      response.content_type = "text/event-stream"
      response.headers["Cache-Control"] = "no-cache"
      response.upgrade do |io|
        stream = Stream.new(io)
        @stream_handler.call(stream, context)
        stream.start
      end
      response
    end
  end
end
