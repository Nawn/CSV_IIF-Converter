require_relative 'converter.rb'
require_relative 'template.rb'

class FileExistContinue < StandardError
end

options = ["BBVA Compass - Noah's Boytique"]

converter = Converter.new

puts "Thank you for using the CSV to IIF file converter"
puts "\n\n\n"

converter.folders()

begin
	puts "Please select import template: \n\n"

	options.each_with_index do |option, idx|
		puts "#{idx+1}: #{option}"
	end

	response = gets.chomp

	case response.to_i
	when 1
		template = Templates::Noah.new
	else
		raise ArgumentError.new("Input does not match any option!\n\n".upcase)
	end
  
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



=begin
#Delete from the imported list of it's either Empty, or begins with anything other than a number (Supposed to be date)

File.open("Example.iif", "w") { |io|
	#Add the header definitions at the top of the IIF.
	headers.each do |header|
		io.write(header.join("\t"))
		io.write("\n")
	end

	file_contents.each do |row|
		amount = row[3] || row[4]
		amount = amount.to_i
		io.write("TRNS\t")
		io.write("#{row[0]}\t") #TOP DATE
		io.write("Checking (X 9317)\t")#TOP ACCNT
		io.write("\t\t")#TOP NAME, TOP CLASS
		io.write("#{amount.to_s}\t")#TOP AMOUNT
		io.write("#{row[1]}\t")#TOP MEMO
		io.write("\n")#ENDL
		io.write("SPL\t")
		io.write("#{row[0]}\t") #BOT DATE
		io.write("Bank Service Charges\t\t")#BOT ACCNT+BOT NAME
		io.write("#{(amount*-1).to_s}\t")#BOT AMOUNT
		io.write("\t\n")#BOT MEMO + ENDL
		io.write("ENDTRNS\t\n") #Next Trans
	end
}
=end