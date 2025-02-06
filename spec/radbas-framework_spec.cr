require "./spec_helper"

describe Radbas do
  describe "application" do
    it "handles default no middleware, no action" do
      app = Radbas::Application.new
      request = HTTP::Request.new "GET", "/"
      output = IO::Memory.new
      response = HTTP::Server::Response.new output
      ctx = HTTP::Server::Context.new request, response
      app.call ctx
      # default HTTP::Handler response
      output.to_s.should eq "HTTP/1.1 404 Not Found\r\n" +
                            "Content-Type: text/plain\r\n" +
                            "Content-Length: 14\r\n" +
                            "\r\n" +
                            "404 Not Found\n"
      response.status_code.should eq 404
    end

    it "handles no middleware, single action" do
      middleware = [] of Radbas::MiddlewareLike
      action = ->(ctx : Radbas::Context) {
        ctx.response.write "Hello World".to_slice
      }
      app = Radbas::Application.new middleware, action
      request = HTTP::Request.new "GET", "/"
      output = IO::Memory.new
      response = HTTP::Server::Response.new output
      response.output = output
      ctx = HTTP::Server::Context.new request, response
      app.call ctx
      output.to_s.should eq "Hello World"
      response.status_code.should eq 200
    end

    it "handles middleware queue" do
      middleware = [
        ->(ctx : Radbas::Context, delegate : Radbas::Next) {
          ctx.response.write "1 ".to_slice
          delegate.call(ctx)
          ctx.response.write "4".to_slice
        },
        ->(ctx : Radbas::Context, delegate : Radbas::Next) {
          ctx.response.write "2 ".to_slice
          delegate.call(ctx)
          ctx.response.write "3 ".to_slice
        },
      ] of Radbas::MiddlewareLike
      action = ->(ctx : Radbas::Context) {
        ctx.response.write "A ".to_slice
      }
      app = Radbas::Application.new middleware, action
      request = HTTP::Request.new "GET", "/"
      output = IO::Memory.new
      response = HTTP::Server::Response.new output
      response.output = output
      ctx = HTTP::Server::Context.new request, response
      app.call ctx
      output.to_s.should eq "1 2 A 3 4"
      response.status_code.should eq 200
    end
  end
end
