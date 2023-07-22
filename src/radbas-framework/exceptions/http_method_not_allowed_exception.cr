class Radbas::Framework::HttpMethodNotAllowedException < Radbas::Framework::HttpException
  getter methods

  def initialize(@context : Context, @methods : Array(String))
    super(context, 405)
  end
end
