
class ACDAConstants

@@acda_userdir 		= ENV["HOME"] + "/.acda"
@@acda_home    		= "."
@@data_plugins_dir 	= @@acda_home + '/data_plugins'
@@disc_plugins_dir 	= @@acda_home + '/disc_plugins'
@@acda_config  		= @@acda_userdir + '/acda.cfg'

def ACDAConstants.input_types()
    types = Hash.new
    types['Title'] = StringType.new("Title")
    types['Description'] = StringType.new("Title")
    return types
end

def ACDAConstants.default_types()
    types = Hash.new
    types.merge!(ACDAConstants.input_types())
    types['Number'] = NumberType.new("Number")
    types['Scanned'] = BoolType.new("Scanned")
    types['AddingDate'] = DateType.new("AddingDate")
    types['ModifiedDate'] = DateType.new("ModifiedDate")
    types['ByteSize'] = NumberType.new("ByteSize")
    types['NumberOfFiles'] = NumberType.new("NumerOfFiles")
    return types
end

def ACDAConstants.acda_userdir
	@@acda_userdir
end

def ACDAConstants.acda_home
	@@acda_home
end

def ACDAConstants.data_plugins_dir
	@@data_plugins_dir
end

def ACDAConstants.disc_plugins_dir
	@@disc_plugins_dir
end

def ACDAConstants.acda_config
	@@acda_config
end

end
