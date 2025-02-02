require "./spec_helper"

describe Radbas do
  describe "application" do
    it "handles a request" do
      app = Radbas::Application.new
      request = HTTP::Request.new "GET", "/"
      output = String::Builder.new
      response = HTTP::Server::Response.new output
      ctx = HTTP::Server::Context.new request, response
      app.call ctx
      response.status_code.should eq 404
    end
  end
end
