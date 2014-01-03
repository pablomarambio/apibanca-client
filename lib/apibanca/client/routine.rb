class Apibanca::Routine < Apibanca::ProxyBase

	set_relative_url "routines"

	def refresh!
		r = Apibanca::Client.get url
		self.merge! r.body
	end

	def turn_on
		r = Apibanca::Client.patch url("turn_on")
		self.merge! r.body
	end

	def turn_off
		r = Apibanca::Client.patch url("turn_off")
		self.merge! r.body
	end

	def schedule params
		raise ArgumentError, "Los parámetros deben ser ApiBanca::Routine::ScheduleParams" unless params.is_a? Apibanca::Routine::ScheduleParams
		r = Apibanca::Client.patch url("schedule"), params.to_hash
		self.merge! r.body
	end

	class ScheduleParams < Hashie::Dash
		property :unit, required: true
		property :interval, required: true
	end
end