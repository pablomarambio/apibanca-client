class Apibanca::Client

	class InvalidOperationError < StandardError
		attr_reader :remote_backtrace, :remote_errors
		def initialize remote_backtrace, remote_errors
			@remote_backtrace = remote_backtrace
			@remote_errors = remote_errors
		end
	end

	class UnauthorizedError < InvalidOperationError; end

	class NotFoundError < InvalidOperationError; end
end