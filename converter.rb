require 'csv'

class Converter
	attr_reader :import_folder, :export_folder
	def initialize
		@import_folder = "csv_file"
		@export_folder = "export"
		@config_folder = "config"
		@folders = [@import_folder, @export_folder, @config_folder]
	end

	def folders
		@folders.each do |folder|
			puts "Checking if #{folder} exists..."
			exists = Dir.exists?(folder)
			puts exists ? "#{folder} Found..\nContinuing.." : "#{folder} not found..\nCreating.."

			unless exists
				Dir.mkdir(folder)
				puts "Create #{folder}: Success..."
			end
			puts "\n\n\n"
		end
	end

	def grab_trans(method=:import)
		#Declare empty Array
		file_contents = []
		
		#For each line in the CSV File
    case method
    when :import
      folder = @import_folder
      filename = "EXPORT.csv"
    when :revise
      folder = @export_folder
      filename = "REVISE.csv"
    end
	    
		CSV.foreach("#{folder}/#{filename}") do |row|
			file_contents << row #Add the row of data as an Array to the file_contents array
		end
		#Return the array of arrays
		file_contents
	end

	def convert(input_array, input_template)
		File.open("#{@export_folder}/COMPLETE.iif", "w") do |io|
			input_template.generate(input_array).each do |row|
				io.write( "#{row.join("\t")}\n" )
			end
		end
	end
end