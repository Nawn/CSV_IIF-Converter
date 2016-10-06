require_relative 'converter.rb'
require_relative 'template.rb'

class FileExistContinue < StandardError
end

options = []

Templates.constants.each_with_index do |constant, idx|
	options << Templates.const_get(constant).new unless idx==0
end

converter = Converter.new

puts "Thank you for using the CSV to IIF file converter"
puts "\n\n\n"

converter.folders()

begin
	puts "Please select import template: \n\n"

	options.each_with_index do |option, idx|
		puts "#{idx+1}: #{option.display_name}"
	end

	response = gets.chomp
	raise ArgumentError.new("\n\nInput must be a number\n\n") unless response =~ /\d+/
	raise ArgumentError.new("\n\nInput must be positive number\n\n") if response.to_i < 1
	
	template = options[response.to_i - 1]
	raise ArgumentError.new("\n\nThat number does not have a Template assigned\n\n") if template.nil?
	
  raise FileExistContinue.new() if File.exists?("#{converter.export_folder}/REVISE.csv")
  
	puts "Please ensure that your CSV file is: \n1.) in the #{converter.import_folder} folder\n2.) titled EXPORT.csv\n3.) Following format: #{template.desc}\n4.) Ensure your comparison file is in the \'config\' folder, titled: #{template.config_name}"
	sleep 1
	system ( "start #{converter.import_folder}" )
	puts "Press enter when you're ready.."
	gets
	raise ArgumentError.new("CSV FILE NOT IN DIRECTORY!\n\n") unless File.exists?("#{converter.import_folder}/EXPORT.csv")
rescue ArgumentError => e
	puts "#{e}"
	retry
rescue FileExistContinue => e
  puts "I Notice that you already have a REVISE file in the #{converter.export_folder}/ folder."
  puts "Would you like to continue using that file? [y/n]"
  system( "start #{converter.export_folder}" )
  Templates::Template.yn_continue("Please remove the REVISE.csv file from the #{converter.export_folder}/ folder.")
	
	#Grab the REVISE.csv file.
	filtered = converter.grab_trans(:revise)
	#Remove the headers that I added to help User know what he's editing Revise.
	filtered.shift
	#Turn the filtered array into an array that becomes IIF when tab-delim
	converter.convert(filtered, template)
end

raw_csv = converter.grab_trans

rejected = raw_csv.reject do |row|
	template.valid_row?(row)
end

repeat = true

display_reject = rejected.map {|row| row << "\n"}.join(", ")

puts "These are the rows that the program will filter out:\n\n#{display_reject}\n\n"

puts "Would you like to continue? [y/n]"

Templates::Template.yn_continue("Please edit your CSV sheet to match the requirements")

desired_rows = raw_csv.find_all {|row| template.valid_row?(row)}

#Filtered will go through the list and apply the rules that we set up(This description math = This name/accnt)
filtered = template.filter(desired_rows)
#This adds header to the CSV so that Alex can know what he's editing and where to edit it.
filtered.unshift(template.temp_header)


#Prints out a Revise
puts "Generating REVISE file in #{converter.export_folder}/..."


CSV.open("#{converter.export_folder}/REVISE.csv", "w") do |csv|
	filtered.each do |row|
		csv << row
	end
end

puts "There is a new file titled REVISE.csv in the #{converter.export_folder} folder"
puts "Please open, and make any changes before we continue. Press enter when you are done."
system ( "start #{converter.export_folder}" )
gets.chomp

#Grab the REVISE.csv file.
filtered = converter.grab_trans(:revise)
#Remove the headers that I added to help User know what he's editing Revise.
filtered.shift
#Turn the filtered array into an array that becomes IIF when tab-delim
converter.convert(filtered, template)

gets.chomp