
require 'Type.rb'

class StringType < Type
	def initialize(name, default = "")
      raise ArgumentError, "Invalid default argument type '#{default.class}'" unless
         default.is_a? String

		super(name, "String", default, Value)
	end
end

class NumberType < Type
	def initialize(name, default = "0")
      raise ArgumentError, "Invalid default argument type '#{default.class}'" unless
         default.is_a? String

		super(name, "Number", default, Value)
	end
end

class BoolType < Type
	def initialize(name, default = "0")
      raise ArgumentError, "Invalid default argument type '#{default.class}'" unless
         default.is_a? String

		super(name, "Bool", default, BoolValue)
	end
end

class ChoiceType < Type
	attr_reader :choices

	def initialize(name, choices, default = "0")
      raise ArgumentError, "Invalid default argument type '#{default.class}'" unless
         default.is_a? String

      raise ArgumentError, "Invalid choices argument '#{choices}'" unless choices.is_a? Array

		@choices = choices
		@pos	 = Hash.new
		hash

		super(name, "Choice", default, ChoiceValue)
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
