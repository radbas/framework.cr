class Radbas::HttpNotFoundException < Radbas::HttpException
  @status = HTTP::Status::NOT_FOUND
end
