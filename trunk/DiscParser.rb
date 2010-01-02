
require 'DirTraverser.rb'
require 'ACDAFile.rb'
require 'DiscPlugins.rb'

class DiscParser
	attr_reader :root
	attr_accessor :disc

	def initialize
		@root = nil
    @disc = nil
	end

	def parse(path)
		if not File.directory?(path)
			raise ArgumentError, "The specified path is not a directory"
		end
		if not File.readable?(path)
			raise ArgumentError, "The specified path is not readable"
		end

		traverser = DirTraverser.new(self)
		traverser.depthTraversal(path)
		return @root
	end

	def addDirectory(parent, path)
		file = ACDAFile.createFromPath(path)
		parent.addChild(file) if parent
		@root = file unless @root
    DiscPlugins.scan_file(disc, file)

		return file
	end

	def addFile(parent, path)
		file = ACDAFile.createFromPath(path)
		if parent
			raise ArgumentError, "The specified parent is not a directory" unless parent.directory?
			parent.addChild(file)
		end
    DiscPlugins.scan_file(disc, file)

		return file
	end
end

if $0 == __FILE__

p = DiscParser.new
puts p.parse('/tmp')

end
