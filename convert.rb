require 'csv'

#Defining headers
top_header = %w(!TRNS DATE ACCNT NAME CLASS AMOUNT MEMO)
mid_header = %w(!SPL DATE ACCNT NAME AMOUNT MEMO)
bot_header = %w(!ENDTRNS)

headers = [top_header, mid_header, bot_header]

#Declare array to store CSV rows
file_contents = []
#For each line in the CSV File
CSV.foreach("EXPORT.csv") do |row|
	file_contents << row #Add the row of data as an Array to the file_contents array
end

File.open("Example.iif", "w") { |io|
	#Add the header definitions at the top of the IIF.
	headers.each do |header|
		io.write(header.join("\t"))
		io.write("\n")
	end
}