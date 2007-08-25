
require 'fileutils.rb'
require 'rexml/document'

require 'ACDA.rb'
require 'Repository.rb'

require 'View.rb'
require 'Disc.rb'
require 'OptionalTypes.rb'
require 'OptionalValue.rb'
require 'ChoiceValue.rb'
require 'exceptions.rb'

class XMLRepository < Repository
include REXML

def initialize(parameter)
	@directory = parameter.sub(/\$\(ACDA_USERDIR\)/, ACDA.acda_userdir)

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
	@fields_doc = Document.new(fields_file)
	@fields_modified = true

	discs_file = File.new(@discs_path)
	@discs_doc = Document.new(discs_file)
	@discs_modified = false
end

def disconnect()
	flush
end

def flush()
	if @fields_modified
		fields_file = File.new(@fields_path, "w")
		@fields_doc.write(fields_file, 0)
	end

	if @discs_modified
		discs_file = File.new(@discs_path, "w")
		@discs_doc.write(discs_file, 0)
	end
end

def getTypes()
	types = Hash.new

	@fields_doc.elements.each("acda-fields/types/*") { |elem|
		case elem.name
			when "number"
				number = nil
				if elem.attributes["default"]
					number = NumberType.new(elem.attributes["id"],
											  elem.attributes["default"].to_i)
				else
					number = NumberType.new(elem.attributes["id"])
				end

				types[number.get_id] = number

			when "text"
				string = nil
				if elem.attributes["default"]
					string = StringType.new(elem.attributes["id"],
										    elem.attributes["default"])
				else
					string = StringType.new(elem.attributes["id"])
				end

				types[string.get_id] = string

			when "choice"
				choices = Array.new

				elem.elements.each("entry") {
                    |entry| choices.push(entry.attributes["name"])
                }

				choice = ChoiceType.new(elem.attributes["id"],
										  choices,
										  elem.attributes["default"])

			 	types[choice.get_id] = choice
			else
				raise RuntimeError, "Unknown optional type #{elem.name}"
		end
	}

	return types
end

def setType(type)
	@fields_doc.elements.delete("acda-fields/types/*[@id='#{type.id}']")

	if type.kind_of? NumberType
		elem = @fields_doc.elements["acda-fields/types"].add_element("number")
		elem.attributes["id"] = type.id
		elem.attributes["default"] = type.default.to_s

	elsif type.kind_of? StringType
		elem = @fields_doc.elements["acda-fields/types"].add_element("text")
		elem.attributes["id"] = type.id
		elem.attributes["default"] = type.default

	elsif type.kind_of? ChoiceType
		elem = @fields_doc.elements["acda-fields/types"].add_element("choice")
		elem.attributes["id"] = type.id
		elem.attributes["default"] = type.default

		type.choices.each { |choice|
			elem.add_element("entry", { "name" => choice })
		}
	end

	@fields_modified = true
end

def remType(type_id)
	type_id = type_id.id if type_id.is_a? OptionalType
	if not @fields_doc.delete("acda-fields/types/*[@id='#{type.id}']")
		raise ArgumentError, "No type with ID #{type.id} found."
	end

	@fields_modified = true
end

def getViews()
	views = Hash.new
    types = getTypes()
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

			view.push_sort(sort.attributes['id'], type)
		}

		views[view.name] = view
	}

	views
end

def setView(view)
	@fields_doc.elements.delete("acda-fields/views/view[@id='#{type.id}']")

	elem = @fields_doc.elements['acda-fields/views'].add_element('view')
	elem.attributes['id'] = view.name

	@fields_modified = true
end

def remView(view_id)
	view_id = view_id.id if view_id.is_a? View
	if not @fields_doc.elements.delete("acda-fields/views/viewid='#{view_id}']")
		raise ArgumentError, "No view with ID #{view_id} found."
	end

	@fields_modified = true
end

def parseDisc(elem, types = getTypes)
	disc = Disc.new(elem.attributes['number'].to_i, elem.attributes['title'])
	elem.elements.each { |sub|
		case sub.name
			# standard attributes
			when 'AddingDate'
				disc.addingDate = ACDADate.new(Time.at(sub.get_text.value.to_i))
			when 'ModifiedDate'
				disc.modifiedDate = ACDADate.new(Time.at(sub.get_text.value.to_i))
			when 'Scanned'
				scanned = false
				val = sub.get_text.value
				if val == '1' or val == 'true'
					disc.scanned = true
				elsif val == '0' or val == 'false'
					disc.scanned = false
				else
					raise RuntimeError,
                        "Unkown value %s for disc %d element Scanned" % 
                        disc.number, val
				end
			when 'NumberOfFiles'
				disc.numberOfFiles = sub.get_text.value.to_i
			when 'BytesSize'
				disc.bytesSize = sub.get_text.value.to_i
			# optional types
			when 'choice'
				type = types[sub.attributes['id']]
                unless type
                    raise ParseError, "Invalid type id '#{sub.attributes['id']}'"
                end
                # factory oder so fuer values
				disc.addValue(ChoiceValue.new(type, sub.text.to_i))
			when 'number'
				type = types[sub.attributes['id']]
                unless type
                    raise ParseError, "Invalid type id '#{sub.attributes['id']}'"
                end
                disc.addValue(OptionalValue.new(type, sub.text.to_i))
			when 'text'
				type = types[sub.attributes['id']]
                unless type
                    raise ParseError, "Invalid type id '#{sub.attributes['id']}'"
                end
				disc.addValue(OptionalValue.new(type, sub.text))
		end
	}
	disc
end

# in the array in no order
def getDiscs()
	discs = Array.new
	types = getTypes

	@discs_doc.elements.each('acda-discs/disc') { |elem|
		disc = parseDisc(elem, types)
		discs.push disc
	}

	discs
end

def getDisc(disc_number)
	elem = @discs_doc.elements["acda-discs/disc[@number='#{disc_number}']"]
	raise RuntimeError, "No disc number #{disc_id} found" unless elem
	return parseDisc(elem)
end

def existsDisc?(disc_number)
	(@discs_doc.elements["acda-discs/disc[@number='#{disc_number}']"]) ? true : false
end

def setDisc(disc)
	if existsDisc?(disc.number)
		raise ArgumentError, "A disc with the number #{disc.number} allready exists"
	end

	elem = @discs_doc.elements['acda-discs'].add_element('disc')
	elem.attributes['number']	= disc.number
	elem.attributes['title']	= disc.title

	elem.add_element('AddingDate').text 	= disc.addingDate.to_i.to_s
	elem.add_element('ModifiedDate').text	= disc.modifiedDate.to_i.to_s
	elem.add_element('Scanned').text		= disc.scanned.to_s
	elem.add_element('BytesSize').text		= disc.bytesSize.to_s
	elem.add_element('NumerOfFiles').text	= disc.numberOfFiles.to_s

	disc.values.each { |value|
		elem_name = ''

		if value.type.kind_of? NumberType
			elem_name = 'number'
		elsif value.type.kind_of? StringType
			elem_name = 'text'
		elsif value.type.kind_of? ChoiceType
			elem_name = 'choice'
		end

		elem.add_element(elem_name).text = value.value.to_s
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
		raise ArgumentError, "Destination disc number #{new_disc_number} allready exists"
	end

	elem = @discs_doc.elements["acda-discs/disc[@number='#{disc_number}']"]
	unless elem
		raise ArgumentError, "No disc with number #{disc_number} found."
	end

	elem.attributes['number'] = new_disc_number

	# Rename files data files :)
	if File.exists?(@files_dir + '/' + disc_number.to_s)
		File.rename(@files_dir + '/' + disc_number.to_s, @files_dir + '/' + new_disc_number.to_s)
	end

	@discs_modified = true;
end

def remDisc(disc_number, delete_files = true)
	unless @discs_doc.elements.delete("acda-discs/disc[@number='#{disc_number}']")
		raise ArgumentError, "No disc number #{disc_number} found"
	end

	remFiles(disc_number) if delete_files

	@discs_modified = true
end

def getFile(elem)
    file = ACDAFile.new()
    file.name = elem.elements['name']
    file.path = elem.elements['path']
    file.dir  = (elem.elements['dir'] == 'true')
    file.size = elem.elements['size'].to_i
    file.mod  = elem.elements['mod'].to_i


	children = elem.elements['file']
    if children
        children.each { |child| file.children.push getFile(child) }
    end
end
private :getFile

def getFiles(disc_number)
    file = File.new(@files_dir + "/" + disc_number.to_s, "w")
	unless file
		raise ArgumentError, "No files for disc number #{disc_number} found"
	end

    doc = Document.new(file)

	elem = doc.elements["acda-files[@disc='#{disc_number}']"]
	unless elem
		raise RuntimeError, "A file for disc #{disc_number} was found but it has a different content."
	end

    root = getFile(elem)
end

def addFile(parent, file)
	elem = parent.add_element('file')
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
	doc.write(file, 0)
end

def remFiles(disc_disc)
    unless File.exists?(@files_dir + "/" + disc_number.to_s)
		raise ArgumentError, "No files for disc number #{disc_number} found"
    end
        
    File.unlink(@files_dir + "/" + disc_number.to_s)
end

private

def XMLRepository.createFieldsDefault(path)
	FileUtils.copy(ACDA.acda_home + "/examples/acda-fields.xml", path)
end

def XMLRepository.createDiscsDefault(path)
	FileUtils.copy(ACDA.acda_home + "/examples/acda-discs.xml", path)
end

end

if $0 == __FILE__
	rep = XMLRepository.new("$(ACDA_USERDIR)/xml-repo")
	rep.connect
	rep.getTypes.each { |x| puts x.inspect }
	rep.setType(NumberType.new("Erneuert", 1))
	rep.setType(ChoiceType.new("Tolle Preise", %w/Haus Auto Garten Fahrrad Apfel Birne Gurke/))
	rep.flush
	puts "-----------"
	rep.getViews.each { |x| puts x.inspect }
	puts "-----------"
	rep.getDiscs.each { |x| puts x.inspect }
	rep.setDisc(Disc.new(10, 'Testdisc', false, 42))
	rep.renumberDisc(10, 9)
	rep.changeDisc(Disc.new(9, 'Testdisc2', false, 420))
	puts "...."
	rep.getDiscs.each { |x| puts x.inspect }
else
    Persistance.register(
        RepositoryDefinition.new(
            'xml', 'XML Files', 'Data is stored in XML files.', XMLRepository
        )
    )
end
