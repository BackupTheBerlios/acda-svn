#!/usr/bin/ruby

require 'ACDA.rb'
require 'ACDAConfig.rb'
require 'ACDAClient.rb'
require 'Persistance.rb'
require 'AlignPrinter.rb'

require 'getoptlong'

options = [
    [ '--scan', '-s', GetoptLong::NO_ARGUMENT      ],
    [ '--view', '-v', GetoptLong::REQUIRED_ARGUMENT],
    [ '--help', '-h', GetoptLong::NO_ARGUMENT      ]
];

def printHelp()
    print <<EOT
Usage: acda [options] <action> ...

 list    - Lists all stored discs
 show    - Displays information about a disc
 search  - Search for a disc
 add     - Adds a new disc
 remove  - Removes a disc
 scan    - Scans a disc for files

Options:

 -h      - Print this help
 -v      - Select a view
 -s      - Scan the disc while adding
EOT
end

def parseOptions(opts)
    arguments = Hash.new
    opts.each do |opt, arg|
        case opt 
            when '--scan'
                arguments['scan'] = true
            when '--view'
                arguments['view'] = arg
            when '--help'
                arguments['help'] = true
        end
    end

    return arguments
end

opts = GetoptLong.new(*options)

arguments = parseOptions(opts)
action    = ARGV.shift()

if arguments['help'] or not action or action == 'help'
    printHelp()
    exit
end

case action
when 'list'
    begin
    client = ACDAClient.new
    client.load_config()
  #  puts client.inspect
    if arguments['view']
        view = client.get_view(arguments['view'])
    else
        view = client.default_view
    end
  #  puts view.inspect
    printer = AlignPrinter.new
    printer.setCaptions(view.field_displays)
    view.process(client.get_discs) { |fields|
        printer.addLine(fields)
    }
    printer.flush
    rescue NoSuchView => ex
        puts ex
    end
when 'show'
when 'search'
when 'add'
when 'remove'
when 'scan'
else
    puts "Unknown action '#{action}'"
end
