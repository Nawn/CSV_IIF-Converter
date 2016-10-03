require_relative 'converter.rb'
require_relative 'template.rb'

options = ["BBVA Compass - Noah's Boytique"]

converter = Converter.new

puts "Thank you for using the CSV to IIF file converter"
puts "Please press enter to begin..."
gets

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

	puts "Please ensure that your CSV file is: \n1.) in the #{converter.import_folder} folder\n2.) titled EXPORT.csv\n3.) Following format: #{template.desc}\n4.) Ensure your comparison file is in the \'config\' folder, titled: #{template.config_name}"
	puts "Press enter when you're ready.."
	gets
	raise ArgumentError.new("CSV FILE NOT IN DIRECTORY!\n\n") unless File.exists?("#{converter.import_folder}/EXPORT.csv")
rescue ArgumentError => e
	puts "#{e}"
	retry
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

filtered = template.filter(desired_rows)

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