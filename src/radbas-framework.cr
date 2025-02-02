require "http/server"
require "json"
require "radbas-routing"

module Radbas
  VERSION = "0.3.0"

  alias Request = ::HTTP::Request
  alias Response = ::HTTP::Server::Response
  alias Context = ::HTTP::Server::Context
  alias Next = ::Proc(Context, Nil)
  alias ActionLike = Next | Action
  alias MiddlewareLike = ::Proc(Context, Next, Nil) | Middleware
  alias SocketHandlerLike = ::Proc(::HTTP::WebSocket, Context, Nil) | SocketHandler
  alias StreamHandlerLike = ::Proc(ServerSentEvents::Stream, Context, Nil) | StreamHandler

  module Middleware
    abstract def call(context : Context, delegate : Next)
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

  module ErrorHandler
    abstract def handle(exception : Exception, context : Context)
  end
end

require "./radbas-framework/ext/context"
require "./radbas-framework/exceptions/http_exception"
require "./radbas-framework/exceptions/*"
require "./radbas-framework/middleware_runner"
require "./radbas-framework/middleware/logging_middleware"
require "./radbas-framework/middleware/error_middleware"
require "./radbas-framework/middleware/routing_middleware"
require "./radbas-framework/middleware/endpoint_middleware"
require "./radbas-framework/middleware_collector"
require "./radbas-framework/route_collector"
require "./radbas-framework/http_head_handler"
require "./radbas-framework/common_error_handler"
require "./radbas-framework/web_socket_action"
require "./radbas-framework/server_sent_events"
require "./radbas-framework/application"
require "./radbas-framework/application_server"
require "./radbas-framework/application_builder"
