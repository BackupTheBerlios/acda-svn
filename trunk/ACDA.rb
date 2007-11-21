
class ACDA

@@acda_userdir 		= ENV["HOME"] + "/.acda"
@@acda_home    		= "."
@@data_plugins_dir 	= @@acda_home + '/data_plugins'
@@disc_plugins_dir 	= @@acda_home + '/disc_plugins'
@@acda_config  		= @@acda_userdir + '/acda.cfg'

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
