module Hashie
	class Mash < Hash

		KEY_FORMATTABLE_TO_DATETIME = /_datetime$/

		def parse_dates! what=nil
			what ||= self
			if what.is_a? Array
				what.each do |elem|
					next if elem.nil?
					parse_dates!(elem) if (elem.is_a?(Hashie::Mash) || elem.is_a?(Array))
				end
			elsif what.is_a? Hashie::Mash
				added = []
				what.each_key do |k|
					if what[k].nil?
						next
					elsif k.to_s =~ KEY_FORMATTABLE_TO_DATETIME and what[k]
						added << { "#{k.to_s.gsub("_datetime", "")}_string".to_sym => what[k] }
						what[k] = DateTime.strptime what[k] rescue nil
					else
						parse_dates!(what[k]) if (what[k].is_a?(Hashie::Mash) || what[k].is_a?(Array))
					end
				end
				added.each do |h|
					what.merge! h
				end
			end
		end
		
	end
end