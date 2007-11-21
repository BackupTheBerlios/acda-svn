
require "Value.rb"

class ChoiceValue < Value
	def initialize(type, value)
		super(type, value)
	end

    def display_value()
        @type.choices[@value]
    end

    def get_value(value)
        ChoiceValue.new(value)
    end

	def <=>(other)
        raise ArgumentError, "Invalid comparison." unless
            other and other.is_a? ChoiceValue
		@value <=> other.value
	end
end
