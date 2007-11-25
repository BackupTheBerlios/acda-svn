
class ACDA

@@acda_userdir 		= ENV["HOME"] + "/.acda"
@@acda_home    		= "."
@@data_plugins_dir 	= @@acda_home + '/data_plugins'
@@disc_plugins_dir 	= @@acda_home + '/disc_plugins'
@@acda_config  		= @@acda_userdir + '/acda.cfg'

def ACDA.input_types()
    types = Hash.new
    types['Title'] = StringType.new("Title")
    types['Description'] = StringType.new("Title")
    return types
end

def ACDA.default_types()
    types = Hash.new
    types.merge!(ACDA.input_types())
    types['Number'] = NumberType.new("Number")
    types['Scanned'] = BoolType.new("Scanned")
    types['AddingDate'] = DateType.new("AddingDate")
    types['ModifiedDate'] = DateType.new("ModifiedDate")
    types['ByteSize'] = NumberType.new("ByteSize")
    types['NumberOfFiles'] = NumberType.new("NumerOfFiles")
    return types
end

def ACDA.acda_userdir
	@@acda_userdir
end

def ACDA.acda_home
	@@acda_home
end

def ACDA.data_plugins_dir
	@@data_plugins_dir
end

def ACDA.disc_plugins_dir
	@@disc_plugins_dir
end

def ACDA.acda_config
	@@acda_config
end

end
