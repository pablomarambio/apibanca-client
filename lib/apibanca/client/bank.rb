class Apibanca::Bank < Apibanca::ProxyBase

	set_relative_url "banks"

	class << self
		def create bank_params
			raise ArgumentError, "Los parámetros deben ser ApiBanca::Bank::Params" unless bank_params.is_a? Apibanca::Bank::Params
			r = Apibanca::Client.post url, { bank: bank_params.to_hash }
			bank = Apibanca::Bank.new(r.body)
			bank.routines.map! { |r| Apibanca::Routine.new(r) }
			bank
		end

		def load id, recursive=true
			r = Apibanca::Client.get url("#{id}")
			bank = Apibanca::Bank.new(r.body)
			bank.routines.map! { |r| Apibanca::Routine.new(r) }
			bank.routines.each { |r| r.refresh! } if recursive
			bank
		end
	end

	def refresh! recursive=true
		r = Apibanca::Client.get url
		old_routines = self.routines
		self.merge! r.body
		self.routines = old_routines
		self.routines.each { |r| r.refresh! } if recursive
		self
	end

	def change_password new_pass
		r = Apibanca::Client.patch url("change_password"), pass: new_pass
		true
	end

	class Params < Hashie::Dash
		property :name, :required => true
		property :user, :required => true
		property :account, :required => true
		property :pass, :required => true
	end
end