class Radbas::Framework::HttpHeadHandler
  include HTTP::Handler

  private class VoidOutput < IO
    def initialize(@response : HTTP::Server::Response)
      @closed = false
      @original_output = @response.output
      @out_count = 0
    end

    def read(slice : Bytes)
      raise NotImplementedError.new("read from HTTP::Server::Response not possible")
    end

    def write(slice : Bytes) : Nil
      @out_count += slice.bytesize
    end

    def close : Nil
      return if closed?
      @closed = true
      status = @response.status
      set_content_length = !(status.not_modified? || status.no_content? || status.informational?)
      if set_content_length && !@response.headers.has_key?("Content-Length")
        @response.content_length = @out_count
      end
      super
      @original_output.close
    end

    def closed? : Bool
      @closed
    end
  end

  def call(context)
    if context.request.method == "HEAD"
      context.response.output = VoidOutput.new(context.response)
    end
    call_next(context)
  end
end
