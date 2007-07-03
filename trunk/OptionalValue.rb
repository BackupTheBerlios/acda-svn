
class OptionalValue
	include Comparable

	attr_reader :type
	attr_accessor :value

	def initialize(type, value = nil)
		@type = type
		@value = (value) ? value : type.default
	end

	def to_s()
		@value.to_s
	end

	def <=>(other)
		value <=> other.value
	end
end
