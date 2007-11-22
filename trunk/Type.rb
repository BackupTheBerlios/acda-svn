
class Type
	attr_reader :default, :name, :type_name, :value_type

	def initialize(name, type_name, default, value_type)
      unless name and type_name and default and value_type
          raise ArgumentError, "Arguments are not allowed to be nil"
      end

		@name = name
		@type_name = type_name
      @value_type = value_type
		@default = default
	end

    def get_value(value)
        @value_type.new(self, value)
    end
end
