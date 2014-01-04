module Faraday
	class Request
		class ApibancaRequestLogger < Middleware

			def call(env)
				puts "  -> #{env[:method].upcase} #{env[:url]} #{env[:body] ? "[#{env[:body]} params]" : "" }"
				@app.call(env)
			end

		end
		Faraday.register_middleware :request, apibanca_request_logger: lambda { ApibancaRequestLogger }
	end
end