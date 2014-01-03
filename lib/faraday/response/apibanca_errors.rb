module Faraday
	class Response
		class ApibancaErrors < Middleware

			def call(env)
				@app.call(env).on_complete do
					resp = env[:response].body
					case env[:status]
					when 401, 403
						raise Apibanca::Client::UnauthorizedError.new(resp.backtrace, nil), resp.error
					when 400, 404..499
						raise Apibanca::Client::InvalidOperationError.new(resp.backtrace, resp[:"object-errors"]), resp.error
					end
				end
			end

		end
		Faraday.register_middleware :response, apibanca_errors: lambda { ApibancaErrors }
	end
end