class Radbas::HttpBadRequestException < Radbas::HttpException
  @status = HTTP::Status::BAD_REQUEST
end
