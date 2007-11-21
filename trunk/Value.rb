
class Value
	include Comparable

	attr_accessor :value

	def initialize(type, value = nil)
        raise ArgumentError, "Invalid type parameter specified." unless type.is_a? Type
		@type = type
		@value = (value) ? value : @type.default
	end

    def type()
        @type
    end

    def name()
        @type.name()
    end

    def display_value()
        @value.to_s
    end

	def to_s()
		@value.to_s
	end

	def <=>(other)
        raise ArgumentError, "Invalid comparison." unless
            other and other.class == self.class
		@value <=> other.value
	end
end
