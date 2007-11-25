
require 'ACDA.rb'
require 'DiscPlugin.rb'
require 'Type.rb'

class DefaultPlugin < DiscPlugin

def initialize(parameter)
end

def self.get_types()
    return Hash.new
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
