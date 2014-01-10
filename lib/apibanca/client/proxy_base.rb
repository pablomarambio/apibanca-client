class Apibanca::ProxyBase < Hashie::Mash
	class << self
		def set_relative_url relative
			self.class_eval(<<-EOM, __FILE__, __LINE__ + 1)
				def url extra=nil
					"#{relative}/\#{self.id}\#{extra ? "/" + extra : ""}"
				end

				def self.url extra=nil
					"#{relative}/\#{extra ? "/" + extra : ""}"
				end
			EOM
		end
	end

	def inspect
		to_s
	end

	def initialize(client, source_hash = nil, default = nil, &block)
		super(source_hash, default, &block)
		@obj_client = client
	end

	# json-friendly
	def remove_references
		@obj_client = nil
	end

	def obj_client
		@obj_client
	end
end