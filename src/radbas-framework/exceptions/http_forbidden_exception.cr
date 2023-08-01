class Radbas::HttpForbiddenException < Radbas::HttpException
  @status = HTTP::Status::FORBIDDEN
end
