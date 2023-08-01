class Radbas::HttpUnauthorizedException < Radbas::HttpException
  @status = HTTP::Status::UNAUTHORIZED
end
