class Apibanca::Job < Apibanca::ProxyBase

	set_relative_url "jobs"

	class << self
		def load client, id
			r = client.get url("#{id}")
			job = Apibanca::Job.new(client, r.body)
			job
		end
	end

end