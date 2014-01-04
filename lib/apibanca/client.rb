require "hashie"
require "faraday"
require "faraday_middleware"
require "apibanca/client/version"
require "apibanca/client/exceptions"
require "faraday/request/apibanca_request_logger"
require "faraday/response/apibanca_errors"

module Apibanca
	class Client

		class << self
			def get uri, params=nil
				Apibanca::Client.conn_url.get do |req|
					req.url uri, params
					req.headers['bc-auth-token'] = @secret
				end
			end

			def post uri, body=nil
				Apibanca::Client.conn_form.post do |req|
					req.url uri
					req.headers['bc-auth-token'] = @secret
					req.body = body if body
				end
			end

			def patch uri, body=nil
				Apibanca::Client.conn_form.patch do |req|
					req.url uri
					req.headers['bc-auth-token'] = @secret
					req.body = body if body
				end
			end

			def delete uri
				Apibanca::Client.conn_form.delete do |req|
					req.url uri
					req.headers['bc-auth-token'] = @secret
				end
			end

			def conn_json
				check_requirements!
				@conn ||= Faraday.new(:url => @base_uri) do |f|
					f.request :apibanca_request_logger
					f.request :json
					f.response :apibanca_errors
					f.response :mashify
					f.response :json, :content_type => /\bjson$/
					f.adapter Faraday.default_adapter
				end
			end

			def conn_url
				check_requirements!
				@conn ||= Faraday.new(:url => @base_uri) do |f|
					f.request :apibanca_request_logger
					f.request :url_encoded
					f.response :apibanca_errors
					f.response :mashify
					f.response :json, :content_type => /\bjson$/
					f.adapter Faraday.default_adapter
				end
			end

			def configure &block
				raise ArgumentError, "El bloque debe recibir un argumento" unless block.arity == 1
				yield self
			end

			def secret= value
				@secret = value
			end

			def secret
				@secret
			end

			def base_uri= value
				@base_uri = value
			end

			def base_uri
				@base_uri ||= "http://localhost:3000/api/2013-11-4"
			end

			private
			def check_requirements!
				raise ArgumentError, "Debe indicar el secreto" unless secret
				raise ArgumentError, "Debe indicar la URI" unless base_uri
			end
		end
	end
end

require "apibanca/client/proxy_base"
require "apibanca/client/bank"
require "apibanca/client/deposit"
require "apibanca/client/routine"
