class Radbas::HttpUnauthorizedException < Radbas::HttpException
  def initialize(@context : Context)
    super(context, HTTP::Status::UNAUTHORIZED)
  end
end
