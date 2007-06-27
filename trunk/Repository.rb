
class Repository
attr_reader :name, :desc

def initialize(name, desc)
	@name = name
	@desc = desc
end

def connect()
end

def disconnect()
end

def flush()
end

def getTypes()
end

def setType(type)
end

def remType(type_id)
end

def getViews()
end

def setView(view)
end

def remView(view_id)
end

def getDiscs()
end

def getDisc(disc_number)
end

def existsDisc?(disc_number)
end

def setDisc(disc)
end

def changeDisc(disc)
end

def renumberDisc(disc_number, new_disc_number)
end

def remDisc(disc_id, delete_files = true)
end

def getFiles(disc_number)
end

def setFiles(disc_number, root)
end

def remFiles(disc_disc)
end
end
