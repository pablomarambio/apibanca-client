require "hashie"
require "faraday"
require "faraday_middleware"
require "apibanca/client/version"
require "apibanca/client/exceptions"
require "faraday/response/apibanca_errors"

module Apibanca
	class Client
		SECRET = nil
		BASE_URI = "http://localhost:3000/api/2013-11-4"

		class << self
			def conn_json
				raise ArgumentError, "Debe indicar el secreto" unless SECRET
				raise ArgumentError, "Debe indicar la URI" unless BASE_URI
				@conn ||= Faraday.new(:url => BASE_URI) do |f|
					f.request :json
					f.response :apibanca_errors
					f.response :mashify
					f.response :json
					f.adapter Faraday.default_adapter
				end
			end
		end
	end
end

require "apibanca/client/bank"
