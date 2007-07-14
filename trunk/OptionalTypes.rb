
class OptionalType
	attr_reader :default, :type_name

	def initialize(id, type_name, default)
		@id = id
		@type_name = type_name
		@default = default
	end

    def get_id()
        return @id
    end
end

class StringType < OptionalType
	def initialize(id, default = "")
		super(id, "String", default)
	end
end

class NumberType < OptionalType
	def initialize(id, default = 0)
		super(id, "Number", default)
	end
end

class ChoiceType < OptionalType
	attr_reader :choices

	def initialize(id, choices, default = nil)
		if default.nil?
			default = choices[0]
		elsif default =~ /^\d$/
			default = choices[default.to_i]
		end

		@choices = choices
		@pos	 = Hash.new
		hash

		super(id, "Choice", default)
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
