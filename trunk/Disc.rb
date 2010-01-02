
require 'Value.rb'
require 'OptionalTypes.rb'

class Disc
  attr_accessor :root

	def initialize(number, scanned = false)
		@values = Hash.new

      self.number = number
      self.scanned =scanned
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

    def values
      return @values.values
    end

    def number
      return @values['Number'].value
    end

    def scanned
      return @values['Scanned'].value
    end

    def number=(number)
      add_value(Value.new(NumberType.new("Number"), number))
    end

    def scanned=(scanned)
      add_value(BoolValue.new(BoolType.new("Scanned"), scanned))
    end

    def clear_values
		@values.clear
    end
end
