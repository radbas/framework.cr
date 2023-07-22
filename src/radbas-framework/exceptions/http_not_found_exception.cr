class Radbas::HttpNotFoundException < Radbas::HttpException
  def initialize(@context : Context)
    super(context, 404)
  end
end
