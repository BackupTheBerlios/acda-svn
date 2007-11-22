
require 'ACDA.rb'
require 'DiscPlugin.rb'
require 'Type.rb'

class DefaultPlugin < DiscPlugin

def initialize(parameter)
end

def self.get_types()
    types = Hash.new
    types['Number'] = NumberType.new("Number")
    types['Scanned'] = BoolType.new("Scanned")
    types['Title'] = StringType.new("Title")
    types['AddingDate'] = DateType.new("AddingDate")
    types['ModifiedDate'] = DateType.new("ModifiedDate")
    types['ByteSize'] = NumberType.new("ByteSize")
    types['NumberOfFiles'] = NumberType.new("NumerOfFiles")
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
