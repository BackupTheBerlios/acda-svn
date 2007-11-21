
require 'ACDA.rb'
require 'DiscPlugin.rb'
require 'Type.rb'
require 'Value.rb'

class DateType < Type
def initialize(name, default)
    default = DateValue.new(self, default)
	super(name, "Date", default)
end
end

class DateValue < Value
def to_s
    @value.strftime('%x')
end
end

class BasicInfo < DiscPlugin

def initialize(parameter)
end

def self.get_types()
    Hash.new
end

def add(disc)
        if addingDate
		    @addingDate = addingDate
        else
		    @addingDate = ACDADate.new(Time.now)
        end

		@modifiedDate = modifiedDate
		@modifiedDate = ACDADate.new(Time.now) if not @modifiedDate
end

def scan(disc, path = nil)
end

def modify(disc)
end

end

DiscPlugins.register(
    DiscPluginDefinition.new(
        'basic', 'Basic Information', 'Fetches basic information like adding and modified date.',
        BasicInfo, false, true
    )
)
