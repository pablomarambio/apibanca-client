class Apibanca::Bank < Apibanca::ProxyBase

	set_relative_url "banks"

	TYPES = %w(BANCO\ SCOTIABANK BANCO\ SECURITY BANCO\ SANTANDER BANCO\ ESTADO BANCO\ CORPBANCA BANCO\ DE\ CHILE BANCO\ RABOBANK BANCO\ BBVA BANCO\ UNKNOWN BANCO\ BICE BANCO\ ITAU BANCO\ BCI BANCO\ BANCO\ INTERNA BANCO\ FALABELLA)

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

		def available client
			r = client.get url("available")
			r.body
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

	def load_jobs params=nil
		r = obj_client.get url, params
		self.jobs = r.body.each do |raw|
			Apibanca::Job.new(obj_client, raw)
		end
	end

	def to_s
		"(BANCO\ #{id}) #{name} / #{user} / #{account}"
	end

	def buc
		"#{name} / User [#{user}] / Cuenta [#{account}]"
	end

	def buc_short
		"#{name}/#{user}/#{account}"
	end

	def search_deposits params={}
		pb = load_deposit_batch params
		PaginatedBatch.new(pb, params, self)
	end

	def load_deposit_batch params={}
		r = obj_client.get url("deposits"), params
		r.body # server paginated batch
	end

	def load_routines! recursive=true
		self.routines.map! { |r| Apibanca::Routine.new(self.obj_client, self, r) }
		self.routines.each { |r| r.refresh! } if recursive
	end
end