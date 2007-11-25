
class Type
	attr_reader :default, :name, :type_name, :value_type

	def initialize(name, type_name, default, value_type)
      unless name and type_name and default and value_type
          raise ArgumentError, "Arguments are not allowed to be nil"
      end
      unless default.is_a? Type or default.is_a? String
        raise ArgumentError, "Default argument need to be a 'Type'"
      end

		@name = name
		@type_name = type_name
        @value_type = value_type
        if default.is_a? Type
		    @default = default
        else
		    @default = @value_type.new(self, default)
        end
	end

    def get_value(value)
        @value_type.new(self, value)
    end
end
