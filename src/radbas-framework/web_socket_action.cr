class Radbas::WebSocketAction
  private alias WebSocket = HTTP::WebSocket
  include Action

  def initialize(@socket_handler : SocketHandlerLike)
  end

  def call(context : Context) : Nil
    request = context.request
    response = context.response

    version = request.headers["Sec-WebSocket-Version"]?
    unless version == WebSocket::Protocol::VERSION
      response.status = :upgrade_required
      response.headers["Sec-WebSocket-Version"] = WebSocket::Protocol::VERSION
      return
    end

    unless key = request.headers["Sec-WebSocket-Key"]?
      raise HttpBadRequestException.new(context, "missing socket key")
    end

    accept_code = WebSocket::Protocol.key_challenge(key)

    response.status = :switching_protocols
    response.headers["Upgrade"] = "websocket"
    response.headers["Connection"] = "Upgrade"
    response.headers["Sec-WebSocket-Accept"] = accept_code
    response.upgrade do |io|
      socket = WebSocket.new(io, sync_close: false)
      @socket_handler.call(socket, context)
      socket.run
    end
  end
end
