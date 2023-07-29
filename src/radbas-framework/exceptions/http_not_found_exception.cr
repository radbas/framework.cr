class Radbas::HttpNotFoundException < Radbas::HttpException
  def initialize(@context : Context)
    super(context, HTTP::Status::NOT_FOUND)
  end
end
