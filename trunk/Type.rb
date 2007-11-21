
class Type
	attr_reader :default, :name, :type_name

	def initialize(name, type_name, default)
        unless name and type_name and default
            raise ArgumentError, "Arguments are not allowed to be nil"
        end

		@name = name
		@type_name = type_name
		@default = Value.new(self, default)
	end

    def get_value(value)
        Value.new(self, value)
    end
end
