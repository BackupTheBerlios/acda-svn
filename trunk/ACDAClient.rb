#!/usr/bin/ruby

require 'ACDA.rb'
require 'ACDAConfig.rb'
require 'Persistance.rb'

class ACDAClient
def initialize()
    @config = ACDAConfig.new(ACDA.acda_config)
    plugin_dir = ACDA.data_plugins_dir
    plugin_dir = @config.values['plugin_dir'] if @config.values['plugin_dir']
    Persistance.load_plugins(plugin_dir)
end

def list_plugins()
    return Persistance.list_plugins()
end

def use_plugin(id, parameter)
    @storage.disconnect() if @storage
    @storage = Persistance.get_plugin(id, parameter)
    @storage.connect()
end

def load_config()
    unless @config.values['plugin']
        raise RuntimeError, "No plugin specified in the config."
    end
    @storage.disconnect() if @storage
    @storage = Persistance.get_plugin(@config.values['plugin'],
                                      @config.values['plugin_param'])
    @storage.connect()
end

def get_types()
    return @storage.getTypes()
end

def get_views()
    return @storage.getViews()
end

def get_view(name)
    ret = @storage.getViews()[name]
    raise NoSuchView, "No such view '#{name}' exists." unless ret
    ret
end

def default_view()
    return @storage.getViews()['default']
end

def get_discs()
    return @storage.getDiscs()
end

# README maybe use this as a library thing to be used by cli and gui

end

if $0 == __FILE__
    client = ACDAClient.new
    client.load_config()
end
