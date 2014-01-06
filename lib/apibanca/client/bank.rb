class Apibanca::Bank < Apibanca::ProxyBase

	set_relative_url "banks"

	class << self
		def create client, bank_params
			raise ArgumentError, "Los parámetros deben ser ApiBanca::Bank::BankCreationParams" unless bank_params.is_a? Apibanca::Bank::BankCreationParams
			r = client.post url, { bank: bank_params.to_hash }
			bank = Apibanca::Bank.new(r.body)
			bank.obj_client = client
			bank.routines.map! { |r| Apibanca::Routine.new(r) }
			bank
		end

		def load client, id, recursive=true
			r = client.get url("#{id}")
			bank = Apibanca::Bank.new(r.body)
			bank.obj_client = client
			bank.routines.map! { |r| Apibanca::Routine.new(r) }
			bank.routines.each { |r| r.refresh! } if recursive
			bank
		end

		def index client, params=nil, recursive=false
			r = client.get url, params
			r.body.map do |raw|
				bank = Apibanca::Bank.new(raw)
				bank.obj_client = client
				bank.routines.map! { |r| Apibanca::Routine.new(r) }
				bank.routines.each { |r| r.refresh! } if recursive
				bank
			end
		end
	end

	def refresh! recursive=true
		r = obj_client.get url
		old_routines = self.routines
		self.merge! r.body
		self.routines = old_routines
		self.routines.each { |r| r.refresh! } if recursive
		self
	end

	def change_password new_pass
		r = obj_client.patch url("change_password"), pass: new_pass
		true
	end

	def add_routine routine_params
		raise ArgumentError, "Los parámetros deben ser ApiBanca::Bank::RoutineCreationParams" unless routine_params.is_a? Apibanca::Bank::RoutineCreationParams
		r = obj_client.post url("add_routine"), { routine: routine_params.to_hash }
		r.body.routines.each do |routine|
			new_routine = Apibanca::Routine.new(routine) unless self.routines.map { |i| i.id }.include?(routine.id)
			next unless new_routine
			new_routine.obj_client = self.obj_client
			new_routine.refresh!
			self.routines << new_routine
		end
	end

	def delete
		r = obj_client.delete url
		true
	end

	def load_deposits params=nil
		r = obj_client.get url("deposits"), params
		self.deposits = r.body.map { |d| nd = Apibanca::Deposit.new(d); nd.obj_bank = self; nd.obj_client = obj_client; nd }
	end

	def to_s
		"Banco #{name} / #{user} / #{account}"
	end

	def inspect
		to_s
	end

	class BankCreationParams < Hashie::Dash
		property :name, :required => true
		property :user, :required => true
		property :account, :required => true
		property :pass, :required => true
	end

	class RoutineCreationParams < Hashie::Dash
		property :nombre, :required => true
		property :target, :required => true
		property :what_to_do, :required => true
	end
end