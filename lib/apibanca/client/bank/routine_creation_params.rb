class Apibanca::Bank
	class RoutineCreationParams < Hashie::Dash
		property :nombre, :required => true
		property :target, :required => true
		property :what_to_do, :required => true
	end
end