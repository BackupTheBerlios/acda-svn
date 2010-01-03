
class ACDAFile
attr_accessor :name, :path, :dir, :size, :mod, :children

def ACDAFile.createFromPath(path)
	stat = File.lstat(path)
	name = File.basename(path)
	dir  = stat.directory?
	size = stat.size
	mod  = stat.mtime.to_i

	ACDAFile.new(name, path, dir, size, mod)
end

def initialize(name = nil, path = nil, dir = nil, size = nil, mod = nil)
	@name = name
	@path = path
	@dir  = dir
	@size = size
	@mod  = mod
	@children = Array.new
end

def display_size
  # TODO make it more intelligent and configurable, extern formatter
  return sprintf("%.2f MiB", size / 1024.0 / 1024.0)
end

def display_lastmod
  Time.at(mod).strftime '%H:%M:%S %d.%m.%Y'
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

