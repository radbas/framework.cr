class Radbas::WebsocketAction
  include Action
  private alias WebSocket = HTTP::WebSocket

  def initialize(@socket_handler : SocketHandlerLike)
  end

  def call(context : Context) : Response
    response = context.response

    version = context.request.headers["Sec-WebSocket-Version"]?
    unless version == WebSocket::Protocol::VERSION
      response.status = :upgrade_required
      response.headers["Sec-WebSocket-Version"] = WebSocket::Protocol::VERSION
      return response
    end

    key = context.request.headers["Sec-WebSocket-Key"]?
    raise HttpBadRequestException.new(context) unless key

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
    response
  end
end
