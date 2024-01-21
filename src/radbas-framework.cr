require "http"
require "json"
require "radbas-routing"

module Radbas
  VERSION = "0.2.0"

  alias Request = HTTP::Request
  alias Response = HTTP::Server::Response
  alias Context = HTTP::Server::Context
  alias ActionLike = Proc(Context, Nil) | Action
  alias MiddlewareLike = Proc(Context, HttpHandler, Nil) | Middleware
  alias SocketHandlerLike = Proc(HTTP::WebSocket, Context, Nil) | SocketHandler
  alias StreamHandlerLike = Proc(ServerSentEvents::Stream, Context, Nil) | StreamHandler

  module Middleware
    abstract def call(context : Context, handler : HttpHandler)
  end

  module Action
    abstract def call(context : Context)
  end

  module SocketHandler
    abstract def call(socket : HTTP::WebSocket, context : Context)
  end

  module StreamHandler
    abstract def call(stream : ServerSentEvents::Stream, context : Context)
  end

  module HttpHandler
    abstract def handle(context : Context)
  end

  module ErrorHandler
    abstract def handle(exception : Exception, context : Context)
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
require "./radbas-framework/web_socket_action"
require "./radbas-framework/server_sent_events"
require "./radbas-framework/application"
