
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

    # Name of the value, e.g. "Title"
    def name()
        @type.name()
    end

    # To be used for display to the user
    def display_value()
        @value.to_s
    end

  # To be used for persistence
	def to_s()
		@value.to_s
	end

	def <=>(other)
        raise ArgumentError, "Invalid comparison." unless
            other and other.class == self.class
		@value <=> other.value
	end
end

# Boolean value, 0, false, 1 and true are allowed as values for persistence
class BoolValue < Value
	def initialize(type, value = nil)
      raise ArgumentError, "Invalid type parameter specified." unless type.is_a? BoolType
      raise ArgumentError, "Invalid value argument type '#{value.class}'" unless
         value.is_a? String or value.is_a? FalseClass or value.is_a? TrueClass

      if value and value.is_a? String
         if value == "0" || value == "false"
            value = false
         elsif value == "1" || value == "true"
            value = true
         else
            raise ArgumentError, "Invalid value argument '#{value}'"
         end
      end

      super(type, value)
	end

   def display_value()
      if @value == true
         return "true"
      else
         return "false"
      end
   end
end
