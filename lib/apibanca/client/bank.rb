class Apibanca::Bank < Apibanca::ProxyBase

	set_relative_url "banks"

	class << self
		def create client, bank_params
			raise ArgumentError, "Los parámetros deben ser ApiBanca::Bank::BankCreationParams" unless bank_params.is_a? Apibanca::Bank::BankCreationParams
			r = client.post url, { bank: bank_params.to_hash }
			bank = Apibanca::Bank.new(client, r.body)
			bank.load_routines! false
			bank
		end

		def load client, id, recursive=true
			r = client.get url("#{id}")
			bank = Apibanca::Bank.new(client, r.body)
			bank.load_routines! recursive
			bank
		end

		def index client, params=nil, recursive=false
			r = client.get url, params
			r.body.map do |raw|
				bank = Apibanca::Bank.new(client, raw)
				bank.load_routines! recursive
				bank
			end
		end
	end

	def refresh! recursive=true
		r = obj_client.get url
		self.merge! r.body
		self.load_routines! recursive
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
			next unless self.routines.any? { |r| r.id == routine.id }
			new_routine = Apibanca::Routine.new(obj_client, self, routine)
			new_routine.refresh!
			self.routines << new_routine
		end
		routines.last
	end

	def delete
		obj_client.delete url
		true
	end

	def load_deposits params=nil
		r = obj_client.get url("deposits"), params
		self.deposits = r.body.map { |d| nd = Apibanca::Deposit.new(obj_client, self, d) }
	end

	def load_jobs params=nil
		r = obj_client.get url, params
		self.jobs = r.body.each do |raw|
			Apibanca::Job.new(obj_client, raw)
		end
	end

	def to_s
		"(Banco #{id}) #{name} / #{user} / #{account}"
	end

	def buc
		"#{name} / User [#{user}] / Cuenta [#{account}]"
	end

	def buc_short
		"#{name}/#{user}/#{account}"
	end

	def load_routines! recursive=true
		self.routines.map! { |r| Apibanca::Routine.new(self.obj_client, self, r) }
		self.routines.each { |r| r.refresh! } if recursive
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