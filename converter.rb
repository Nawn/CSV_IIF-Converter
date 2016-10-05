require 'csv'

class Converter
	attr_reader :import_folder, :export_folder
	def initialize
		@top_row = %w(!TRNS DATE ACCNT NAME CLASS AMOUNT MEMO)
		@mid_row = %w(!SPL DATE ACCNT NAME AMOUNT MEMO)
		@bot_row = %w(!ENDTRNS)
		@headers = [@top_row, @mid_row, @bot_row]
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
		input_array.each do |trns|
			puts trns.inspect
		end
	end
end