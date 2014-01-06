require "hashie"
require "faraday"
require "faraday_middleware"
require "apibanca/client/version"
require "apibanca/client/exceptions"
require "faraday/request/apibanca_request_logger"
require "faraday/response/apibanca_errors"

module Apibanca
	class Client
		module Http
			def get uri, params=nil
				conn_url.get do |req|
					req.url uri, params
					req.headers['bc-auth-token'] = @secret
				end
			end

			def post uri, body=nil
				conn_form.post do |req|
					req.url uri
					req.headers['bc-auth-token'] = @secret
					req.body = body if body
				end
			end

			def patch uri, body=nil
				conn_form.patch do |req|
					req.url uri
					req.headers['bc-auth-token'] = @secret
					req.body = body if body
				end
			end

			def delete uri
				conn_form.delete do |req|
					req.url uri
					req.headers['bc-auth-token'] = @secret
				end
			end

			def conn_form
				check_requirements!
				@conn_form ||= Faraday.new(:url => @base_uri) do |f|
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
				@conn_url ||= Faraday.new(:url => @base_uri) do |f|
					f.request :apibanca_request_logger
					f.request :url_encoded
					f.response :apibanca_errors
					f.response :mashify
					f.response :json, :content_type => /\bjson$/
					f.adapter Faraday.default_adapter
				end
			end
		end
		include Http

		def initialize secret, api_uri = "http://api-banca.herokuapp.com/api/2013-11-4"
			raise ArgumentError, "Debe indicar el secreto para acceder a la API" unless secret
			@secret = secret
			@base_uri = api_uri
		end

		private
		def check_requirements!
			raise ArgumentError, "Debe indicar el secreto" unless @secret
			raise ArgumentError, "Debe indicar la URI" unless @base_uri
		end
	end
end

require "apibanca/client/proxy_base"
require "apibanca/client/bank"
require "apibanca/client/deposit"
require "apibanca/client/deposit_version"
require "apibanca/client/routine"
