require File.expand_path('lib/modifier', File.dirname(__FILE__))
require 'optparse'

options = {
  modification_factor: 1,
  cancellaction_factor: 0.4
}

OptionParser.new do |opts|
  opts.banner = "Usage: modifier.rb [options] filename [filename_2, ...]"

  opts.on("-mM", "--modification_factor=M", "Modification factor (default=1)") do |m|
    options[:modification_factor] = m.to_f
  end

  opts.on("-cC", "--cancellaction_factor=C", "Cancellaction factor (default=0.4)") do |c|
    options[:cancellaction_factor] = c.to_f
  end

  opts.on("-oO", "--output=O", "Output filename") do |o|
    options[:output] = o
  end
end.parse!

if ARGV.empty?
  puts 'Invalid number of arguments. Try to pass --help for more info'
  exit 1
end

modified = options[:output] || ARGV[0]
inputs = ARGV

inputs = inputs.map { |input| Modifier::Utils.latest(input) }
modifier = Modifier.new(options[:modification_factor], options[:cancellaction_factor])
modifier.modify(modified, *inputs)

puts "DONE modifying"
