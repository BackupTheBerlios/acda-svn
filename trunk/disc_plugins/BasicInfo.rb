
require 'ACDAConstants.rb'
require 'DiscPlugin.rb'
require 'Type.rb'
require 'Value.rb'

class DateType < Type
def initialize(name, default = "0")
   raise ArgumentError, "Invalid default argument type '#{default.class}'" unless
      default.is_a? String

	super(name, "Date", default, DateValue)
end
end

class DateValue < Value
def initialize(type, value = nil)
   raise ArgumentError, "Invalid value argument type '#{value.class}'" unless
      value.is_a? String

   if value
      value = Time.at(value.to_i)
   end

   super(type, value)
end

def to_s
   @value.to_i.to_s
end

def display_value()
    @value.strftime('%x')
end
end

class BasicInfo < DiscPlugin

def self.get_types()
    Hash.new
end

def self.add(disc)
# TODO fix
       # if addingDate
		   # @addingDate = addingDate
       # else
		   # @addingDate = ACDADate.new(Time.now)
       # end
		    #@addingDate = ACDADate.new(Time.now)

		#@modifiedDate = modifiedDate
		#@modifiedDate = ACDADate.new(Time.now) if not @modifiedDate
end

def self.scan(disc, path)
end

def self.scan_file(disc, file)
end

def self.modify(disc)
end

end

DiscPlugins.register(
    DiscPluginDefinition.new(
        'basic', 'Basic Information', 'Fetches basic information like adding and modified date.',
        BasicInfo, false, true
    )
)
