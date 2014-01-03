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
			def get uri
				Apibanca::Client.conn_json.get do |req|
					req.url uri
					req.headers['bc-auth-token'] = Apibanca::Client::SECRET
				end
			end

			def post uri, body=nil
				Apibanca::Client.conn_json.post do |req|
					req.url uri
					req.headers['bc-auth-token'] = Apibanca::Client::SECRET
					req.body = body if body
				end
			end

			def patch uri, body=nil
				Apibanca::Client.conn_json.patch do |req|
					req.url uri
					req.headers['bc-auth-token'] = Apibanca::Client::SECRET
					req.body = body if body
				end
			end

			def conn_json
				check_requirements!
				@conn ||= Faraday.new(:url => BASE_URI) do |f|
					f.request :json
					f.response :apibanca_errors
					f.response :mashify
					f.response :json, :content_type => /\bjson$/
					f.adapter Faraday.default_adapter
				end
			end
			private
			def check_requirements!
				raise ArgumentError, "Debe indicar el secreto" unless SECRET
				raise ArgumentError, "Debe indicar la URI" unless BASE_URI
			end
		end
	end
end

require "apibanca/client/bank"
require "apibanca/client/routine"
