#!/usr/bin/ruby

require 'ACDAConstants.rb'
require 'ACDAConfig.rb'
require 'Persistance.rb'
require 'DiscPlugins.rb'
require 'DiscParser.rb'

class ACDAClient
def initialize()
    @config = ACDAConfig.new(ACDAConstants.acda_config)
    @storage = nil
    @types   = nil
    @discs   = nil

    plugin_dir = ACDAConstants.data_plugins_dir
    plugin_dir = @config.values['plugin_dir'] if @config.values['plugin_dir']
    disc_plugin_dir = ACDAConstants.disc_plugins_dir
    disc_plugin_dir = @config.values['disc_plugin_dir'] if @config.values['disc_plugin_dir']
    Persistance.load_plugins(plugin_dir)
    DiscPlugins.load_plugins(disc_plugin_dir)
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
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  unless @types
    @types = DiscPlugins.get_types()
    @types.merge!(ACDAConstants.default_types())
    @types.merge!(@storage.getTypes())
  end

  return @types
end

def get_views()
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  return @storage.getViews()
end

def get_view(name)
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  ret = @storage.getViews(get_types())[name]
  raise NoSuchView, "No such view '#{name}' exists." unless ret
  ret
end

def default_view()
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  return @storage.getViews(get_types())['default']
end

def get_discs()
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  unless @discs
    @discs = @storage.getDiscs(get_types())
  end
  return @discs
end

def get_disc(number)
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  discs = get_discs
  return discs.find { |disc| disc.number == number }
end

def get_files(disc_number)
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  disc = get_disc(disc_number)
  return @storage.getFiles(disc_number)
end

def new_disc()
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end

  return Disc.new(next_disc_number())
end

def scan_disc(disc, path = nil)
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end

  unless path
    path = @config.values['disc_dir']
  end

  unless path
    raise ACDAArgumentError, "No path specified to parse the disc, add a path argument or configure 'disc_dir' in ~/.acda/acda.cfg."
  end
  unless File.directory?(path)
    raise ACDAArgumentError, "The path '#{path}' must be a directory."
  end
  unless File.readable?(path)
    raise ACDAArgumentError, "The path '#{path}' must be readable."
  end

  DiscPlugins.add_disc(disc)
  DiscPlugins.scan_disc(disc, path)

  parser = DiscParser.new
  parser.disc = disc
  parser.parse(path)

  disc.add_value(Value.new(StringType.new("Title"), parser.root.name))
  disc.root = parser.root
  disc.scanned = true

  puts "root: "+ parser.root.name
  puts "disc: "+ disc.get_value('Number').value.to_s
end

def add_disc(disc)
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  
  @storage.setDisc(disc)
  @storage.setFiles(disc.number, disc.root) unless disc.root == nil
  @storage.flush()
end

def rem_disc(number)
  unless @storage
    raise NotInitializedError, "Client not initialized, call load_config first."
  end
  @storage.remDisc(number)
  @storage.flush()
end

private

def next_disc_number()
  discs = get_discs()
  number_map = Hash.new
  discs.each { |disc| number_map[disc.number] = true }
  free_number = 1
  while (number_map.has_key?(free_number))
    free_number += 1
  end
  return free_number
end

end

if $0 == __FILE__
    client = ACDAClient.new
    client.load_config()
end
