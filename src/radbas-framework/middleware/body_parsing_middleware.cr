class Radbas::BodyParsingMiddleware
  include Middleware

  def call(context : Context, handler : HttpHandler) : Response
    request = context.request
    content_type = request.headers["Content-Type"]?
    request_body = request.body
    if request_body && content_type
      case content_type.split(";", 2)[0].strip.downcase
      when "application/json"
        context.parsed_body = JSON.parse(request_body.as(IO))
      when "application/x-www-form-urlencoded"
        context.parsed_body = URI::Params.parse(request_body.as(IO).gets_to_end)
      when "multipart/form-data"
        context.parsed_body = HTTP::Params.new
        HTTP::FormData.parse(request) do |part|
          if part.filename
            context.files[part.name] = File.tempfile("upload") do |file|
              IO.copy(part.body, file)
            end
          else
            context.parsed_body.as(HTTP::Params).add(part.name, part.body.gets_to_end)
          end
        end
      end
    end
    handler.handle(context)
  end
end