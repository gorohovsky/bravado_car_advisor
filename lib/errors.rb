module Errors
  module ExternalApi
    class ErrorResponse < StandardError; end

    class BadResponse < ErrorResponse; end

    class MalformedResponse < ErrorResponse
      def initialize(key, value)
        super()
        @key = key
        @value = value
      end

      def message = "Invalid #{@key}: #{@value.inspect}"
    end
  end
end
