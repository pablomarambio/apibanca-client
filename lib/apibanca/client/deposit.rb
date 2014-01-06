class Apibanca::Deposit < Apibanca::ProxyBase
	def load_history
		h = obj_client.get obj_bank.url("deposits/#{self.id}/history")
		@history = h.body.map { |d| dv = Apibanca::DepositVersion.new(d); dv.obj_deposit = self; dv }
	end

	def to_s
		"#{self.raw_date} #{self.psd_type ? self.psd_type : self.raw_comment} [#{self.raw_amount}]"
	end

	def inspect
		to_s
	end

	def history
		@history ||= load_history
	end
end