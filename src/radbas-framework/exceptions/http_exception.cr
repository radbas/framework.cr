class Radbas::Framework::HttpException < Exception
  getter context, code

  def initialize(@context : Context, @code = 500)
  end
end
