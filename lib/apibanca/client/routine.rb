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

	def set_callback type, uri, options=nil
		r = obj_client.patch url("set_callback"), { cb_type: type, uri: uri, options: options }
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
		@obj_bank = bank
	end

	def obj_bank
		@obj_bank
	end

	class ScheduleParams < Hashie::Dash
		property :unit, required: true
		property :interval, required: true
	end
end