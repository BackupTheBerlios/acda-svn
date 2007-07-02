
class OptionalValue
	include Comparable

	attr_reader :type
	attr_accessor :value

	def initialize(type, value = nil)
		@type = type
		@value = (value) ? value : type.default
	end

	def display_value()
        # TODO implement
		@value
	end

	def <=>(other)
		value <=> other.value
	end
end
