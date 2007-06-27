
require "OptionalValue.rb"

class ChoiceValue < OptionalValue
	def initialize(type, value = nil)
		super
	end

	def <=>(other)
		type.pos[value] <=> other.type.pos[other.value]
	end
end
