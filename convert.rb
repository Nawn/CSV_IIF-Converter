require_relative 'template.rb'
require_relative 'converter.rb'

#To Raise later if the REVISE File exists
class FileExistContinue < StandardError
end

#Declare Empty Array
options = []


#For each Constant (aka class) add an instance of it to options
#It will display the options later. Skip first because that's
#The default Template class
Templates.constants.each_with_index do |constant, idx|
	options << Templates.const_get(constant).new unless idx==0
end

#Declaration
converter = Converter.new

puts "Thank you for using the CSV to IIF file converter"
puts "\n\n\n"

#Checks to see if required folders exist, if not make them
converter.folders()

begin
	puts "Please select import template: \n\n"

	#Display each option to stdout
	options.each_with_index do |option, idx|
		puts "#{idx+1}: #{option.display_name}"
	end

	response = gets.chomp
	#Exception Handling
	raise ArgumentError.new("\n\nInput must be a number\n\n") unless response =~ /\d+/
	raise ArgumentError.new("\n\nInput must be positive number\n\n") if response.to_i < 1
	
	#If it passes the ArgumentErrors, It is a valid input
	#Therefore, if it's valid, make the template whichever space
	#They selected. (Gets rid of a case statement. Saves like6 lines of code)
	template = options[response.to_i - 1]

	#Just in case ;)
	raise ArgumentError.new("\n\nThat number does not have a Template assigned\n\n") if template.nil?
	
	#If they've already begun work, raise this. 
  raise FileExistContinue.new() if File.exists?("#{converter.export_folder}/REVISE.csv")
  
  #Reviewing the steps with the user
	puts "Please ensure that your CSV file is: \n1.) in the #{converter.import_folder} folder\n2.) titled EXPORT.csv\n3.) Following format: #{template.desc}\n4.) Ensure your comparison file is in the \'config\' folder, titled: #{template.config_name}"
	sleep 1
	#This will send Windows a command to open the folder that is 
	#supposed to contain the EXPORT.csv file
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
  user_response = gets.chomp

  case user_response.chomp.downcase
  when 'y'
  	converter.convert(template)
		exit
	when 'n'
		File.delete("#{converter.export_folder}/REVISE.csv")
	else
		puts "I'm sorry I don't understand #{user_response}"
		retry
	end
end

converter.gen_revise(template)

puts "There is a new file titled REVISE.csv in the #{converter.export_folder} folder"
puts "Please open, and make any changes before we continue. Press enter when you are done."
system ( "start #{converter.export_folder}" )
gets.chomp

converter.convert(template)

puts "Complete...\n Thank you!"