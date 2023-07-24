require "http"
require "log"
require "uri"
require "json"
require "radbas-routing"
require "radbas-container"

module Radbas
  VERSION = "0.1.0"

  alias Request = HTTP::Request
  alias Response = HTTP::Server::Response
  alias Context = HTTP::Server::Context
  alias ActionLike = Proc(Context, Response) | Action
  alias MiddlewareLike = Proc(Context, HttpHandler, Response) | Middleware
  alias RouteCollector = Routing::RouteCollector(ActionLike, MiddlewareLike)
  alias Route = Routing::Route(ActionLike, MiddlewareLike)
  alias Router = Routing::Router(Route)

  module Middleware
    abstract def call(context : Context, handler : HttpHandler) : Response
  end

  module Action
    abstract def call(context : Context) : Response
  end

  module HttpHandler
    abstract def handle(context : Context) : Response
  end

  module ErrorHandler
    abstract def handle(context : Context, exception : Exception) : Response
  end
end

require "./radbas-framework/ext/context"
require "./radbas-framework/exceptions/*"
require "./radbas-framework/middleware/error_middleware"
require "./radbas-framework/middleware/routing_middleware"
require "./radbas-framework/middleware/conditional_middleware"
require "./radbas-framework/middleware/action_middleware"
require "./radbas-framework/routing/route"
require "./radbas-framework/routing/route_collector"
require "./radbas-framework/middleware_dispatcher"
require "./radbas-framework/http_head_handler"
require "./radbas-framework/common_error_handler"
require "./radbas-framework/application"
