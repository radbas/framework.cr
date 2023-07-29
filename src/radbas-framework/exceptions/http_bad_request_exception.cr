class Radbas::HttpBadRequestException < Radbas::HttpException
  def initialize(@context : Context)
    super(context, HTTP::Status::BAD_REQUEST)
  end
end
