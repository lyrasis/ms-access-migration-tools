#!/usr/bin/env ruby

require 'fileutils'
require 'optparse'

options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: extract_tsvs.rb -i path-to-db -o path-to-output-directory'

  opts.on('-i', '--input PATH', 'Path to input file (an MS Access db)') do |i|
    options[:input] = File.expand_path(i)
  end

  opts.on('-o', '--outputdir PATH', 'Path to directory in which to save TSVs') do |o|
    options[:output] = File.expand_path(o)
  end

  opts.on('-h', '--help', 'Prints this help') do
    puts opts
    exit
  end
end.parse!

db = options[:input]

# create output directory if it does not exist
FileUtils.mkdir_p(options[:output])

# get list of tables in db
tables = `mdb-tables -1 #{db}`.split("\n")

# export each as a TSV
tables.each do |table|
  tablename = table.gsub(' ', '_').gsub('/', '-')
  tsvname = "#{options[:output]}/#{tablename}.tsv"
  `mdb-export -b strip #{db} "#{table}" | csvformat -T > #{tsvname}`
  puts "Wrote #{tsvname}"
end
