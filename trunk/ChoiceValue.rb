
require "Value.rb"

class ChoiceValue < Value
	def initialize(type, value = nil)
      raise ArgumentError, "Invalid type parameter specified." unless type.is_a? ChoiceType
      raise ArgumentError, "Invalid value argument type '#{value.class}'" unless
         value.is_a? String

		super(type, value.to_i)
	end

   def display_value()
       @type.choices[@value]
   end

	def <=>(other)
        raise ArgumentError, "Invalid comparison." unless
            other and other.is_a? ChoiceValue
		@value <=> other.value
	end
end
