
class OptionalValue
	include Comparable

	attr_accessor :value

	def initialize(type, value = nil)
		@type = type
		@value = (value) ? value : type.default
	end

    def get_type()
        @type
    end

	def to_s()
		@value.to_s
	end

	def <=>(other)
        raise ArgumentError, "Invalid comparison." unless
            other and other.is_a? OptionalValue
		@value <=> other.value
	end
end
