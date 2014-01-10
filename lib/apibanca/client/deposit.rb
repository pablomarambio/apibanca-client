class Apibanca::Deposit < Apibanca::ProxyBase
	def load_history
		h = obj_client.get obj_bank.url("deposits/#{self.id}/history")
		@history = h.body.map { |d| dv = Apibanca::DepositVersion.new(d); dv.obj_deposit = self; dv }
	end

	def to_s
		"(Deposit #{id}) #{self.raw_date} / #{self.psd_type ? self.psd_type : self.raw_comment} / #{self.raw_amount}"
	end

	def history
		@history ||= load_history
	end

	def initialize(client, bank, source_hash = nil, default = nil, &block)
		super(client, source_hash, default, &block)
		@obj_bank = bank
	end

	def remove_references
		super
		@obj_bank = nil
	end

	def obj_bank
		@obj_bank
	end
end