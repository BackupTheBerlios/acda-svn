
class ACDAFile
attr_accessor :name, :path, :dir, :size, :mod, :children

def ACDAFile.createFromPath(path)
	stat = File.stat(path)
	name = File.basename(path)
	dir  = stat.directory?
	size = stat.size
	mod  = stat.mtime.to_i

	ACDAFile.new(name, path, dir, size, mod)
end

def initialize(name, path, dir, size, mod)
	@name = name
	@path = path
	@dir  = dir
	@size = size
	@mod  = mod
	@children = Array.new
end

def directory?
	dir
end

def addChild(child)
	@children.push child
end

def to_s
	s = ''
	s << "name:  " + @name		+ "\n"
	s << "path:  " + @path 		+ "\n"
	s << "dir:   " + @dir.to_s 	+ "\n"
	s << "size:  " + @size.to_s + "\n"
	s << "mod:   " + @mod.to_s 	+ "\n"
	@children.each { |child| s << "---\n" << child.to_s }
	s
end

end

