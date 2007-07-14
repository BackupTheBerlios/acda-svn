
require "OptionalValue.rb"

class ChoiceValue < OptionalValue
	def initialize(type, value = nil)
		super(type, value)
	end

    def to_s()
        @type.choices[value]
    end

	def <=>(other)
		@value <=> other.value
	end
end
