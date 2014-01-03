module Faraday
	class Response
		class ApibancaErrors < Middleware

			def call(env)
				@app.call(env).on_complete do
					resp = env[:response].body
					if env[:status] >= 400 && env[:status] <= 500
						if resp.respond_to? :backtrace
							case env[:status]
							when 401, 403
								raise Apibanca::Client::UnauthorizedError.new(resp.backtrace, nil), resp.error
							when 404
								raise Apibanca::Client::UnauthorizedError.new(resp.backtrace, nil), resp.error
							else
								raise Apibanca::Client::InvalidOperationError.new(resp.backtrace, resp[:"object-errors"]), resp.error
							end
						else
							raise "Error inesperado #{env[:status]}"
						end
					end
				end
			end

		end
		Faraday.register_middleware :response, apibanca_errors: lambda { ApibancaErrors }
	end
end