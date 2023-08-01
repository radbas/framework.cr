class Radbas::HttpMethodNotAllowedException < Radbas::HttpException
  getter methods

  @status = HTTP::Status::METHOD_NOT_ALLOWED

  def initialize(context : Context, @methods : Array(String))
    super(context)
  end
end
