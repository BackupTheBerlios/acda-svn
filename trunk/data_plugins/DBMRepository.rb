
require 'sdbm'
require 'ACDA.rb'
require 'Repository.rb'

require 'OptionalTypes.rb'

class DBMRepository < Repository

def initialize(parameter)
	@directory = parameter.sub(/\$\(ACDA_USERDIR\)/, ACDA.acda_userdir)

	super("dbm", "Stores the repository in DBM files in '#{@directory}'")

	@files_dir = @directory + "/files"

	@fields_path = @directory + "/acda-fields.dbm"
	@discs_path  = @directory + "/acda-discs.dbm"
	
	@fields_modified = false
	@discs_modified  = false
end

def connect()
	if ! File.exist?(@directory)
		Dir.mkdir(@directory)
	end
	if ! File.exist?(@files_dir)
		Dir.mkdir(@files_dir)
	end
	if ! File.readable?(@fields_path)
		XMLRepository.createFieldsDefault(@fields_path)
	end
	if ! File.readable?(@discs_path)
		XMLRepository.createDiscsDefault(@discs_path)
	end
	

	fields_file = File.new(@fields_path)
	@fields_doc = Document.new(fields_file)
	@fields_modified = true

	discs_file = File.new(@fields_path)
	@discs_doc = Document.new(discs_file)
	@discs_modified = false
end

private

def DBMRepository.createFieldsDefault(path)
	FileUtils.copy(ACDA.acda_home + "/examples/acda-fields.dbm", path)
end

def DBMRepository.createDiscsDefault(path)
	FileUtils.copy(ACDA.acda_home + "/examples/acda-discs.dbm", path)
end

end
