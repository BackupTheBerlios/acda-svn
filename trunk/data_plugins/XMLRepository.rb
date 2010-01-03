
require 'fileutils.rb'
require 'rexml/document'

require 'ACDAConstants.rb'
require 'Repository.rb'

require 'View.rb'
require 'Disc.rb'
require 'ChoiceValue.rb'
require 'OptionalTypes.rb'
require 'exceptions.rb'

class XMLRepository < Repository
include REXML

def initialize(parameter)
	@directory = parameter.sub(/\$\(ACDA_USERDIR\)/, ACDAConstants.acda_userdir)

	super("xml", "Stores the repository in XML files in '#{@directory}'")

	@files_dir = @directory + "/files"

	@fields_path = @directory + "/acda-fields.xml"
	@discs_path  = @directory + "/acda-discs.xml"
	
	@fields_modified = false
	@discs_modified = false
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
   begin
	@fields_doc = Document.new(fields_file)
	@fields_modified = true

   rescue REXML::ParseException => ex
      raise RepositoryError, "The disc xml document '@discs_path' is invalid:\n"+
                              ex
   end

	discs_file = File.new(@discs_path)
   begin
	@discs_doc = Document.new(discs_file)
	@discs_modified = false

   rescue REXML::ParseException => ex
      raise RepositoryError, "The disc xml document '@discs_path' is invalid:\n"+
                              ex
   end
end

def disconnect()
	flush
end

def flush()
	if @fields_modified
		fields_file = File.new(@fields_path, "w")
		@fields_doc.write(fields_file)
	end

	if @discs_modified
		discs_file = File.new(@discs_path, "w")
		@discs_doc.write(discs_file)
	end
end

# TODO do not use calmel case
def getTypes()
	types = Hash.new

	@fields_doc.elements.each("acda-fields/types/*") { |elem|
		case elem.name
			when "number"
				number = nil
				if elem.attributes["default"]
					number = NumberType.new(elem.attributes["id"],
											  elem.attributes["default"])
				else
					number = NumberType.new(elem.attributes["id"])
				end

				types[number.name] = number

			when "text"
				string = nil
				if elem.attributes["default"]
					string = StringType.new(elem.attributes["id"],
										    elem.attributes["default"])
				else
					string = StringType.new(elem.attributes["id"])
				end

				types[string.name] = string

			when "choice"
				choices = Array.new

				elem.elements.each("entry") {
                    |entry| choices.push(entry.attributes["name"])
                }

            if elem.attributes["default"]
				   choice = ChoiceType.new(elem.attributes["id"],
										choices,	elem.attributes["default"])
            else
				   choice = ChoiceType.new(elem.attributes["id"], choices)
            end

			 	types[choice.name] = choice
			else
				raise RuntimeError, "Unknown optional type #{elem.name}"
		end
	}

	return types
end

def setType(type)
	@fields_doc.elements.delete("acda-fields/types/*[@id='#{type.name}']")

    # TODO use ROXML
    # Use classes and mapping table for types, plugin style, no hardcoded stuff
	if type.kind_of? NumberType
		elem = @fields_doc.elements["acda-fields/types"].add_element("number")
		elem.attributes["id"] = type.name
		elem.attributes["default"] = type.default.to_s

	elsif type.kind_of? StringType
		elem = @fields_doc.elements["acda-fields/types"].add_element("text")
		elem.attributes["id"] = type.name
		elem.attributes["default"] = type.default.to_s

	elsif type.kind_of? ChoiceType
		elem = @fields_doc.elements["acda-fields/types"].add_element("choice")
		elem.attributes["id"] = type.name
		elem.attributes["default"] = type.default.to_s

		type.choices.each { |choice|
			elem.add_element("entry", { "name" => choice })
		}
	end

	@fields_modified = true
end

def remType(type_id)
	type_id = type_id.name if type_id.is_a? Type
	if not @fields_doc.delete("acda-fields/types/*[@id='#{type.name}']")
		raise ACDAArgumentError, "No type with ID #{type.name} found."
	end

	@fields_modified = true
end

def getViews(types)
	views = Hash.new
	@fields_doc.elements.each('acda-fields/views/view') { |elem|
		view = View.new(elem.attributes['id'], types)

		# add fields
		elem.elements.each('field') { |field|
			view.push_field(field.attributes['id'],
							field.attributes['display'])
		}

		# add sorts
		elem.elements.each('sort') { |sort|
			type = View.ASCENDING

			if sort.attributes['type'] == 'ascending' or
			   sort.attributes['type'] == 'asc'
			   type = View.ASCENDING
			elsif sort.attributes['type'] == 'descending' or
				  sort.attributes['type'] == 'dsc'
			   type = View.DESCENDING
			else
				raise ParseError, "Unknown sort type %s" % sort.attributes['type']
			end

            unless types[sort.attributes['id']]
				raise ParseError, "Invalid sort id '%s'" % sort.attributes['id']
            end

			view.push_sort(types[sort.attributes['id']], type)
		}

		views[view.name] = view
	}

	views
end

def setView(view)
	@fields_doc.elements.delete("acda-fields/views/view[@id='#{type.name}']")

	elem = @fields_doc.elements['acda-fields/views'].add_element('view')
	elem.attributes['id'] = view.name

	@fields_modified = true
end

def remView(view_id)
	view_id = view_id.id if view_id.is_a? View
	if not @fields_doc.elements.delete("acda-fields/views/viewid='#{view_id}']")
		raise ACDAArgumentError, "No view with ID #{view_id} found."
	end

	@fields_modified = true
end

def parseDisc(elem, types)
    scanned = false
    if elem.attributes['scanned'] == '0'
        scanned = false
    elsif elem.attributes['scanned'] == '1'
        scanned = true
    else
        raise ParseError, "Disc number #{elem.attributes['number']} attribute scanned has an invalid value"
    end

	disc = Disc.new(elem.attributes['number'].to_i, scanned)
	elem.elements.each { |sub|
		type = types[sub.attributes['name']]
        unless type
            raise ParseError, "Invalid type name '#{sub.attributes['name']}'"
        end
		disc.add_value(type.get_value(sub.text))
	}
	disc
end

# in the array in no order
def getDiscs(types)
	discs = Array.new

	@discs_doc.elements.each('acda-discs/disc') { |elem|
		disc = parseDisc(elem, types)
		discs.push disc
	}

	discs
end

def getDisc(disc_number)
	elem = @discs_doc.elements["acda-discs/disc[@number='#{disc_number}']"]
	raise ACDAArgumentError, "No disc number #{disc_number} found" unless elem
	return parseDisc(elem)
end

def existsDisc?(disc_number)
	(@discs_doc.elements["acda-discs/disc[@number='#{disc_number}']"]) ? true : false
end

def setDisc(disc)
	if existsDisc?(disc.number)
		raise ACDAArgumentError, "A disc with the number #{disc.number} allready exists"
	end

	elem = @discs_doc.elements['acda-discs'].add_element('disc')

	elem.attributes['number']  = disc.number.to_s
	elem.attributes['scanned'] = (disc.scanned) ? "1" : "0"

	disc.values.each { |value|
    next if value.name == 'Scanned' || value.name == 'Number'
    value_elem = elem.add_element('value')
		value_elem.attributes['name'] = value.name
		value_elem.text = value.to_s
	}

	@discs_modified = true
end

def changeDisc(disc)
	unless @discs_doc.elements.delete("acda-discs/disc[@number='#{disc.number}']")
		raise RuntimeError, "No disc number #{disc.number} found"
	end

	setDisc(disc)
end

def renumberDisc(disc_number, new_disc_number)
	if existsDisc?(new_disc_number)
		raise ACDAArgumentError, "Destination disc number #{new_disc_number} allready exists"
	end

	elem = @discs_doc.elements["acda-discs/disc[@number='#{disc_number}']"]
	unless elem
		raise ACDAArgumentError, "No disc with number #{disc_number} found."
	end

	elem.attributes['number'] = new_disc_number.to_s

	# Rename files data files :)
	if File.exists?(@files_dir + '/' + disc_number.to_s)
		File.rename(@files_dir + '/' + disc_number.to_s, @files_dir + '/' + new_disc_number.to_s)
	end

	@discs_modified = true;
end

def remDisc(disc_number, delete_files = true)

	unless @discs_doc.elements.delete("acda-discs/disc[@number='#{disc_number}']")
		raise ACDAArgumentError, "No disc number #{disc_number} found"
	end

	remFiles(disc_number) if delete_files

	@discs_modified = true
end

def getFile(elem)
  file = ACDAFile.new()
  file.name = elem.elements['name'].text
  file.path = elem.elements['path'].text
  file.dir  = (elem.elements['dir'].text == 'true')
  file.size = elem.elements['size'].text.to_i
  file.mod  = elem.elements['mod'].text.to_i


	children = elem.get_elements('file')
  if children
    children.each { |child| file.children.push getFile(child) }
  end
  return file
end
private :getFile

def getFiles(disc_number)
  filename = @files_dir + "/" + disc_number.to_s
	unless File.file?(filename)
		raise ACDAArgumentError, "No files for disc number #{disc_number} found"
	end
    file = File.new(filename, "r")

    doc = Document.new(file)

	elem = doc.elements["acda_files[@disc='#{disc_number}']"]
	unless elem
		raise RuntimeError, "Inconsistency, files for disc #{disc_number} was found but it has a different content."
	end

    return getFile(elem.get_elements('/acda_files/file')[0])
end

def addFile(parent, file)
	elem = parent.add_element('file')
    # static attributes not nice for entity class persistation, roxml?
	elem.add_element('name').text = file.name
	elem.add_element('path').text = file.path
	elem.add_element('dir').text  = file.dir.to_s
	elem.add_element('size').text = file.size.to_s
	elem.add_element('mod').text  = file.mod.to_s

    file.children.each { |child| addFile(elem, child) }
end
private :addFile

def setFiles(disc_number, root)
    doc  = Document.new()
	root_elem = doc.add_element('acda_files')
	root_elem.attributes['disc'] = disc_number

    addFile(root_elem, root)

    file = File.new(@files_dir + "/" + disc_number.to_s, "w")
	doc.write(file)
end

def remFiles(disc_number)
    # No check for existance here, it might not be present. Checking if the
    # disc has any file is to much work, just see if there are files or not.
    #
    #unless File.exists?(@files_dir + "/" + disc_number.to_s)
		#raise ACDAArgumentError, "No files for disc number #{disc_number} found"
    #end
        
    File.unlink(@files_dir + "/" + disc_number.to_s)
end

private

def XMLRepository.createFieldsDefault(path)
	FileUtils.copy(ACDAConstants.acda_home + "/examples/acda-fields.xml", path)
end

def XMLRepository.createDiscsDefault(path)
	FileUtils.copy(ACDAConstants.acda_home + "/examples/acda-discs.xml", path)
end

end

if $0 == __FILE__
	rep = XMLRepository.new("$(ACDA_USERDIR)/xml-data")
	rep.connect

	types = rep.getTypes
	puts "---- TYPES -------"
    types.each { |x| puts x.inspect }
    require 'DiscPlugins.rb'
    DiscPlugins.load_plugins(ACDAConstants.disc_plugins_dir)
    dpTypes = DiscPlugins.get_types()
	puts "-------- PLUGIN TYPES -----"
    dpTypes.each { |x| puts x.inspect }
	puts "----------------------------"
    dpTypes.each { |a,b| types[a] = b}

	rep.setType(NumberType.new("Erneuert", 1))
	rep.setType(ChoiceType.new("Tolle Preise", %w/Haus Auto Garten Fahrrad Apfel Birne Gurke/))
	rep.flush
	puts "------------ VIEWS --------------"
	rep.getViews(types).each { |x| puts x.inspect }
	puts "------------ DISCS --------------"
	rep.getDiscs(types).each { |x| puts x.inspect }
	rep.setDisc(Disc.new(10, false))
	rep.renumberDisc(10, 9)
	rep.changeDisc(Disc.new(9, false))
	puts "...."

	rep.getDiscs(types).each { |x| puts x.inspect }
else
    Persistance.register(
        RepositoryDefinition.new(
            'xml', 'XML Files', 'Data is stored in XML files.', XMLRepository
        )
    )
end
