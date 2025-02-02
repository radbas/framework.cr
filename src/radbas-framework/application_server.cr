class Radbas::ApplicationServer
  def initialize(
    @application : HTTP::Handler,
    @logger = Log.for("radbas.server"),
  )
  end

  private getter server : HTTP::Server {
    HTTP::Server.new([HttpHeadHandler.new, @application])
  }

  def bind(uri : String) : self
    server.bind(uri)
    self
  end

  def bind(host : String, port : Int32, reuse_port = false) : self
    server.bind_tcp(host, port, reuse_port)
    self
  end

  def listen : Nil
    return if server.listening?
    if server.addresses.empty?
      bind = server.bind_tcp("0.0.0.0", 8080)
      @logger.warn { "no socket bound, using default #{bind}" }
    end
    server.each_address do |address|
      @logger.info { "server listening on #{address}" }
    end
    Signal::INT.trap &->shutdown(Signal)
    Signal::TERM.trap &->shutdown(Signal)
    server.listen
  end

  private def shutdown(signal : Signal) : Nil
    @logger.info { "server shutdown" }
    close
    exit
  end

  def close : Nil
    server.close unless server.closed?
  end
end
