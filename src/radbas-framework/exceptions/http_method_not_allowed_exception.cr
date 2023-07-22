class Radbas::HttpMethodNotAllowedException < Radbas::HttpException
  getter methods

  def initialize(@context : Context, @methods : Array(String))
    super(context, 405)
  end
end
