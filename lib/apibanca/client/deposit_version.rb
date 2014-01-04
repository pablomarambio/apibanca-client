class Apibanca::DepositVersion < Apibanca::Deposit

	def load_history
		raise "Para cargar la historia, debes hacerlo en la versión actual del depósito"
	end

	def history
		raise "Para revisar la historia, debes hacerlo en la versión actual del depósito"
	end
end