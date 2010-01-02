
class RepositoryDefinition
	attr_accessor :name, :long_name, :desc, :plugin, :path

	def initialize(name, long_name, desc, plugin, path = nil)
		@name	= name
		@long_name = long_name
		@desc  	= desc
		@plugin = plugin
		@path  	= path
	end

	def to_s()
		s  = "#{@long_name} [#{@name}]: #{@desc}"
		s += " #{@path}" if @path
		return s
	end
end

class Persistance
	@@plugins = Hash.new

def self.register(definition)
	@@plugins[definition.name] = definition;
end

def self.load_plugins(plugins_dir)
    unless File.directory?(plugins_dir)
        raise ArgumentError, "Plugin path '#{plugins_dir}' is not existing or "+
                             "not a directory."
    end

	Dir[plugins_dir + "/*.rb"].each do |pluginfile|
		load pluginfile
	end
end

def self.list_plugins()
	@@plugins
end

def self.get_plugin(name, parameter)
	if ! @@plugins[name]
		raise ArgumentError, "Unknown Repository '#{name}'"
	end

	return @@plugins[name].plugin.new(parameter)
end
end

if __FILE__ == $0
  require 'ACDAConstants.rb'
    
	Persistance.load_plugins(ACDAConstants.data_plugins_dir)
	Persistance.list_plugins().each do |name, info|
		puts info
	end

	a = Persistance.get_plugin('xml', '$ACDA_USERDIR');
end
	
