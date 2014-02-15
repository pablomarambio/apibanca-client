class Apibcanca::Bank
	class BankCreationParams < Hashie::Dash
		property :name, :required => true
		property :user, :required => true
		property :account, :required => true
		property :pass, :required => true
	end
end