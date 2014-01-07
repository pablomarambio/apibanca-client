class Apibanca::Routine < Apibanca::ProxyBase

	set_relative_url "routines"

	def refresh!
		r = obj_client.get url
		self.merge! r.body
	end

	def turn_on
		r = obj_client.patch url("turn_on")
		self.merge! r.body
	end

	def turn_off
		r = obj_client.patch url("turn_off")
		self.merge! r.body
	end

	def schedule params
		raise ArgumentError, "Los parámetros deben ser ApiBanca::Routine::ScheduleParams" unless params.is_a? Apibanca::Routine::ScheduleParams
		r = obj_client.patch url("schedule"), params.to_hash
		self.merge! r.body
	end

	def load_tasks
		r = obj_client.get url("tasks")
		self.tasks = r.body
	end

	def delete
		obj_client.delete url
		self.obj_bank.routines.select! { |r| r.id != self.id } if self.obj_bank.routines.any?
		true
	end

	def to_s
		"(Rutina #{id}) #{nombre} #{target ? "#{what_to_do}:#{target}" : ""} tasks=#{scheduled_tasks} #{!active ? "INACTIVE" : ""}"
	end

	def initialize(client, bank, source_hash = nil, default = nil, &block)
		super(client, source_hash, default, &block)
		self.obj_bank = bank
	end

	class ScheduleParams < Hashie::Dash
		property :unit, required: true
		property :interval, required: true
	end
end