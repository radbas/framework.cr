require "http"
require "log"
require "radbas-routing"
require "radbas-container"

module Radbas::Framework
  VERSION = "0.1.0"

  alias Request = HTTP::Request
  alias Response = HTTP::Server::Response
  alias Context = HTTP::Server::Context
  alias ActionArgs = Hash(String, String)
  alias ActionLike = Proc(Context, Response) | Action
  alias MiddlewareLike = Proc(Context, HttpHandler, Response) | Middleware
  alias RouteCollector = Routing::RouteCollector(ActionLike | Action.class, MiddlewareLike | Middleware.class)
  alias Route = Routing::Route(ActionLike | Action.class, MiddlewareLike | Middleware.class)
  alias Router = Routing::Router(Route)

  abstract class Middleware
    abstract def call(context : Context, handler : HttpHandler) : Response
  end

  abstract class Action
    abstract def call(context : Context) : Response
  end

  abstract class HttpHandler
    abstract def handle(context : Context) : Response
  end

  abstract class ErrorHandler
    abstract def handle(context : Context, exception : Exception) : Response
  end
end

require "./radbas-framework/ext/context"
require "./radbas-framework/resolver"
require "./radbas-framework/exceptions/*"
require "./radbas-framework/middleware/*"
require "./radbas-framework/routing/route"
require "./radbas-framework/routing/route_collector"
require "./radbas-framework/middleware_dispatcher"
require "./radbas-framework/http_head_handler"
require "./radbas-framework/default_error_handler"
require "./radbas-framework/application"
