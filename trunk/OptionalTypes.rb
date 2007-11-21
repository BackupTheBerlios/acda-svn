
require 'Type.rb'

class StringType < Type
	def initialize(name, default = "")
        default = Value.new(self, default)
		super(name, "String", default)
	end
end

class NumberType < Type
	def initialize(name, default = 0)
        default = Value.new(self, default)
		super(name, "Number", default)
	end
end

class ChoiceType < Type
	attr_reader :choices

	def initialize(name, choices, default = nil)
		if default.nil?
			default = ChoiceValue.new(self, 0)
		elsif default =~ /^\d$/
			default = ChoiceValue.new(self, default.to_i)
        else
            raise ArgumentError, "Invalid default argument '#{default}'"
		end

        raise ArgumentError, "Invalid choices argument '#{choices}'" unless choices.is_a? Array

		@choices = choices
		@pos	 = Hash.new
		hash

		super(name, "Choice", default)
	end

    def get_value(value)
        return ChoiceValue.new(self, value.to_i)
    end

	def push_choice(choice)
		@choices.push choice
		hash
	end

	def add_choice(pos, choice)
		@choices[pos, 0] = choice
		hash
	end

	def del_choice(pos)
		@choices.delete_at(pos)
	end

	def move_choice(pos, rel)
		@choices[pos + rel, 0] = @choices.delete_at(pos)
		hash
	end

	def position(value)
		@pos[value]
	end

	private

	def hash()
		@pos.clear
		@choices.each_index { |i| @pos[@choices[i]] = i }
	end
end
