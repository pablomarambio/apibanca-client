class Apibanca::Bank
	class PaginatedBatch
		include Enumerable
		extend Forwardable
		def_delegators :@records, :each
		def initialize(pb, params, bank)
			@bank = bank
			@params = params
			parse_response pb
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
			parse_response(@bank.load_deposit_batch params)
		end

		def parse_response response
			raise ArgumentError, "Batch inválido" unless valid_paginated_batch? response
			@records = response.records.map { |r| m = Apibanca::Deposit.new(@bank.obj_client, @bank, r); m.parse_dates!; m }
			@length = response.total_records
			@total_pages = response.total_pages
			@page = response.page
		end
	end
end