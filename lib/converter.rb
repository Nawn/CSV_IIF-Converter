require 'csv'
require_relative 'template.rb'

class Converter
	attr_reader :import_folder, :export_folder

	def initialize
		@import_folder = "csv_file"
		@export_folder = "export"
		@config_folder = "config"
		@folders = [@import_folder, @export_folder, @config_folder]
	end

	#Checks to see if the required folders (declared above) exist
	#If they do not, it will recreate them.
	def folders
		@folders.each do |folder|
			puts "Checking if #{folder} exists..."
			exists = Dir.exists?(folder)
			puts exists ? "#{folder} Found..\nContinuing.." : "#{folder} not found..\nCreating.."

			unless exists
				Dir.mkdir(folder)
				puts "Create #{folder}: Success..."
			end
			puts "\n\n"
		end
	end

	def grab_trans(method=:import)
		#Declare empty Array
		file_contents = []
		
		#Depending on the symbol parameter, it will pull from
		#The appropriate CSV file
    case method
    when :import
      folder = @import_folder
      filename = "EXPORT.csv"
    when :revise
      folder = @export_folder
      filename = "REVISE.csv"
    end
	  
	  #For Each line in the CSV file, generate an 2D Array
	  #Full of transaction data
		CSV.foreach("#{folder}/#{filename}") do |row|
			file_contents << row #Add the row of data as an Array to the file_contents array
		end
		#Return the array of arrays
		file_contents
	end

	#Generate the Revise csv file
	def gen_revise(template)
		#Grab Trans will pull from EXPORT.csv because no args
		raw_csv = grab_trans

		#Rejected is an array of transactions that did not meet
		#Criteria
		rejected = raw_csv.reject do |row|
			template.valid_row?(row)
		end

		#Display_reject is just the array turned into a string
		display_reject = rejected.map {|row| row << "\n"}.join(", ")

		puts "These are the rows that the program will filter out:\n\n#{display_reject}\n\n"

		puts "Would you like to continue? [y/n]"

		#Y/N to either exit or continue
		Templates::Template.yn_continue("Please edit your CSV sheet to match the requirements")

		#Same as Display_reject, however only returns rows that match
		desired_rows = raw_csv.find_all {|row| template.valid_row?(row)}

		#Filtered will go through the list and apply the rules that we set up(This description math = This name/accnt)
		filtered = template.filter(desired_rows)
		#This adds header to the CSV so that Alex can know what he's editing and where to edit it.
		filtered.unshift(template.temp_header)


		#Prints out a Revise
		puts "Generating REVISE file in #{@export_folder}/..."

		#Open the file REVISE.CSV (Create it) and for each row of data
		#Convert it to CSV format
		CSV.open("#{@export_folder}/REVISE.csv", "w") do |csv|
			filtered.each do |row|
				csv << row
			end
		end
	end

	def convert(input_template)
		#Grab the revisions
		to_go = grab_trans(:revise)
		#Remove the headers that I added for Users
		to_go.shift

		#Then manually create an IIF file
		File.open("#{@export_folder}/COMPLETE.iif", "w") do |io|
			input_template.generate(to_go).each do |row|
				io.write( "#{row.join("\t")}\n" )
			end
		end
	end
end