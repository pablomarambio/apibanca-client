class Apibanca::Bank < Apibanca::ProxyBase

	set_relative_url "banks"

	class << self
		def create bank_params
			raise ArgumentError, "Los parámetros deben ser ApiBanca::Bank::BankCreationParams" unless bank_params.is_a? Apibanca::Bank::BankCreationParams
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

		def index recursive=false
			r = Apibanca::Client.get url
			r.body.map do |raw|
				bank = Apibanca::Bank.new(raw)
				bank.routines.map! { |r| Apibanca::Routine.new(r) }
				bank.routines.each { |r| r.refresh! } if recursive
				bank
			end
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

	def add_routine routine_params
		raise ArgumentError, "Los parámetros deben ser ApiBanca::Bank::RoutineCreationParams" unless routine_params.is_a? Apibanca::Bank::RoutineCreationParams
		r = Apibanca::Client.post url("add_routine"), { routine: routine_params.to_hash }
		r.body.routines.each do |routine|
			new_routine = Apibanca::Routine.new(routine) unless self.routines.map { |i| i.id }.include?(routine.id)
			next unless new_routine
			new_routine.refresh!
			self.routines << new_routine
		end
	end

	def delete
		r = Apibanca::Client.delete url
		true
	end

	def load_deposits params=nil
		r = Apibanca::Client.get url("deposits"), params
		self.deposits = r.body.map { |d| Apibanca::Deposit.new(d) }
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