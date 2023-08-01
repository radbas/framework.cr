class Radbas::HttpException < Exception
  getter context, status

  @status = HTTP::Status::INTERNAL_SERVER_ERROR

  def initialize(@context : Context, message : String? = nil, cause : Exception? = nil)
    super(message, cause)
  end
end
