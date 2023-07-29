class Radbas::HttpMethodNotAllowedException < Radbas::HttpException
  getter methods

  def initialize(@context : Context, @methods : Array(String))
    super(context, HTTP::Status::METHOD_NOT_ALLOWED)
  end
end
