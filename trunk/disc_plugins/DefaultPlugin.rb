
require 'ACDA.rb'
require 'DiscPlugin.rb'
require 'Type.rb'

class DefaultPlugin < DiscPlugin

def initialize(parameter)
end

def self.get_types()
    types = Hash.new
    types['Number'] = NumberType.new("Number", 0)
    types['Scanned'] = NumberType.new("Scanned", 0)
    types['Title'] = StringType.new("Title", 0)
    types['AddingDate'] = DateType.new("AddingDate", 0)
    types['ModifiedDate'] = DateType.new("ModifiedDate", 0)
    types['ByteSize'] = NumberType.new("ByteSize", 0)
    types['NumberOfFiles'] = NumberType.new("NumerOfFiles", 0)
    return types
end

def add(disc)
end

def scan(disc, path = nil)
end

def modify(disc)
end

end

DiscPlugins.register(
    DiscPluginDefinition.new(
        'default', 'Default Types plugin', 'Plugin to register the default types.',
        DefaultPlugin, false, false
    )
)
