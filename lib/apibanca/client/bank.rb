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

	def deposits params=nil, page: 1
		
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

	def search_deposits params={}
		pb = load_deposit_batch params
		batch = PaginatedBatch.new(pb, params, self)
	end

	def load_deposit_batch params={}
		r = obj_client.get url("deposits"), params
		r.body # server paginated batch
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

	class PaginatedBatch
		include Enumerable
		extend Forwardable
		def_delegators :@records, :each
		def initialize(pb, params, bank)
			raise ArgumentError unless valid_paginated_batch? pb
			@bank = bank
			@records = pb.records
			@length = pb.total_records
			@total_pages = pb.total_pages
			@page = pb.page
			@params = params
		end

		def next_page
			raise "No hay más registros" if @page == @total_pages
			n_page = @page + 1
			load_page n_page
		end

		def previous_page
			raise "Estás en la primera página" if @page == 0
			n_page = @page - 1
			load_page n_page
		end

		def length
			@length
		end
		alias_method :total_records, :length

		def total_pages
			@total_pages
		end
		alias_method :pages, :total_pages

		def current_page
			@page
		end
		alias_method :page, :current_page

		def inspect
			"#{@records.length}/#{self.length} depósitos [página #{self.page}/#{self.pages}]"
		end

		private
		def valid_paginated_batch?(pb=nil)
			pb ||= @pb
			pb.total_pages && pb.total_pages.is_a?(Fixnum) &&
			pb.total_records && pb.total_records.is_a?(Fixnum) &&
			pb.page && pb.page.is_a?(Fixnum) &&
			pb.records && pb.records.is_a?(Array) && pb.records.any?
		end

		def load_page page_number
			params = @params.merge({page: page_number})
			pb = @bank.load_deposit_batch params
			@page = page_number
			@records = pb.records
		end
	end
end