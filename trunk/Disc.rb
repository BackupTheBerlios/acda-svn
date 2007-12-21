
require 'Value.rb'
require 'OptionalTypes.rb'

class Disc
	attr_reader :values

	def initialize(number, scanned = false)
		@values = Hash.new

      @values['Number']  = Value.new(NumberType.new("Number"), number)
      @values['Scanned'] = BoolValue.new(BoolType.new("Scanned"), scanned)
	end

	def add_value(value)
        unless value or value.is_a? Value
            raise RuntimeError, "Invalid type added."
        end
		@values[value.name] = value
	end

    def get_value(name)
        return @values[name]
    end

    def number
      return @values['Number'].value
    end

    def scanned
      return @values['Scanned'].value
    end

    def clear_values
		@values.clear
    end
end
