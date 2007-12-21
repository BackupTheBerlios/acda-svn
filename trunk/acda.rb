#!/usr/bin/ruby

require 'ACDA.rb'
require 'ACDAConfig.rb'
require 'ACDAClient.rb'
require 'Persistance.rb'
require 'AlignPrinter.rb'

require 'getoptlong'

options = [
    [ '--scan', '-s', GetoptLong::NO_ARGUMENT      ],
    [ '--sort', '-o', GetoptLong::NO_ARGUMENT      ],
    [ '--view', '-v', GetoptLong::REQUIRED_ARGUMENT],
    [ '--no-caption', '-n', GetoptLong::NO_ARGUMENT],
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
 -n      - No table caption
 -s      - Scan the disc while adding
 -o      - Sort the output if possible
EOT
end

def parseOptions(opts)
    arguments = Hash.new
    opts.each do |opt, arg|
        case opt 
            when '--scan'
                arguments['scan'] = true
            when '--sort'
                arguments['sort'] = true
            when '--view'
                arguments['view'] = arg
            when '--no-caption'
                arguments['nocaption'] = true
            when '--help'
                arguments['help'] = true
        end
    end

    return arguments
end

#
# Main
#

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
    # Initialize the client
    client = ACDAClient.new
    client.load_config()

    # Get the correct view
    if arguments['view']
        view = client.get_view(arguments['view'])
    else
        view = client.default_view
    end

    # Get the discs and let them be processed by the view,
    # then send it to the output printer
    printer = AlignPrinter.new
    printer.set_captions(view.field_displays) unless arguments['nocaption']
    view.process(client.get_discs) { |fields|
        printer.add_line(fields)
    }
    printer.flush

    rescue NoSuchView => ex
        $stderr.puts ex
    rescue RepositoryError => ex
        $stderr.puts ex
    end
when 'show'
    begin
    if ARGV.size <= 0
       $stderr.puts "Please specify a disc to show."
       exit -1
    end

    # Initialize the client
    client = ACDAClient.new
    client.load_config()

    printer = AlignPrinter.new
    printer.set_captions(["Attribute", "Value"]) unless arguments['nocaption']

    ARGV.each { |argument|
        number = argument.to_i
        unless argument == number.to_s
            $stderr.puts "Invalid disc number '#{argument}'."
            exit -1
        end

        disc = client.get_disc(number)

        unless disc
            $stderr.puts "No disc number #{number} found."
            exit -1
        end

        # Print the discs attributes
        if (arguments['sort'])
            keys = disc.values.keys.sort
        else
            keys = disc.values.keys
        end
        keys.each { |key|
            value = disc.values[key]
            printer.add_line([value.name, value.display_value])
        }

        if argument != ARGV[-1]
           printer.add_separator
        end
    }

    printer.flush

    rescue RepositoryError => ex
        $stderr.puts ex
    end
when 'search'
when 'add'
when 'remove'
when 'scan'
else
    puts "Unknown action '#{action}'"
end
