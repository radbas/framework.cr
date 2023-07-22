class Radbas::Framework::HttpNotFoundException < Radbas::Framework::HttpException
  def initialize(@context : Context)
    super(context, 404)
  end
end
