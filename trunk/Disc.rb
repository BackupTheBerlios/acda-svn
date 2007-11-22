
require 'Value.rb'
require 'OptionalTypes.rb'

class Disc
	attr_reader :number, :values, :scanned

	def initialize(number, scanned = false)
		@number	 = number
		@scanned = scanned

		@values = Hash.new
	end

	def add_value(value)
        unless value or value.is_a? Value
            raise RuntimeError, "Invalid type added."
        end
		@values[value.name] = value
	end

    def get_value(name)
        case name
            when "Number"
                return Value.new(NumberType.new("Number"), @number)
            when "Scanned"
                return Value.new(BoolType.new("Scanned"), @scanned)
            else
#                unless @values[id]
#                    raise NoSuchField, "No field with id '#{id}' found." 
#                end
                return @values[name]
        end
    end

	def clear_values
		@values.clear
	end
end
