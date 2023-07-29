class Radbas::HttpException < Exception
  getter context, status

  def initialize(@context : Context, @status = HTTP::Status::INTERNAL_SERVER_ERROR)
    @message = @status.description
  end
end
