require "http"
require "json"
require "radbas-routing"
require "radbas-container"

module Radbas
  VERSION = "0.2.0"

  alias Request = HTTP::Request
  alias Response = HTTP::Server::Response
  alias Context = HTTP::Server::Context
  alias ActionLike = Proc(Context, Response) | Action
  alias MiddlewareLike = Proc(Context, HttpHandler, Response) | Middleware
  alias SocketHandlerLike = Proc(HTTP::WebSocket, Context, Response) | SocketHandler

  module Middleware
    abstract def call(context : Context, handler : HttpHandler) : Response
  end

  module Action
    abstract def call(context : Context) : Response
  end

  module SocketHandler
    abstract def call(socket : HTTP::WebSocket, context : Context) : Response
  end

  module HttpHandler
    abstract def handle(context : Context) : Response
  end

  module ErrorHandler
    abstract def handle(context : Context, exception : Exception) : Response
  end
end

require "./radbas-framework/ext/context"
require "./radbas-framework/exceptions/http_exception"
require "./radbas-framework/exceptions/*"
require "./radbas-framework/middleware/error_middleware"
require "./radbas-framework/middleware/routing_middleware"
require "./radbas-framework/middleware/action_middleware"
require "./radbas-framework/routing/route"
require "./radbas-framework/routing/route_collector"
require "./radbas-framework/middleware_dispatcher"
require "./radbas-framework/http_head_handler"
require "./radbas-framework/common_error_handler"
require "./radbas-framework/websocket_action"
require "./radbas-framework/application"
