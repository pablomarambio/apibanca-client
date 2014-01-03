class Apibanca::Bank < Hashie::Dash
	property :name, :required => true
	property :user, :required => true
	property :account, :required => true
	property :pass

	class << self
		def create(bank)
			Apibanca::Client.conn_json.post do |req|
				req.url 'banks'
				req.headers['bc-auth-token'] = Apibanca::Client::SECRET
				req.body = { bank: bank.to_hash }
			end
		end
	end
end