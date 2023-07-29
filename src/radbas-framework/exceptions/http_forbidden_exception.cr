class Radbas::HttpForbiddenException < Radbas::HttpException
  def initialize(@context : Context)
    super(context, HTTP::Status::FORBIDDEN)
  end
end
