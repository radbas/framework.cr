class Radbas::HttpBadRequestException < Radbas::HttpException
  def initialize(@context : Context)
    super(context, 400)
  end
end
