require 'csv'

#Defining headers
top_header = %w(!TRNS DATE ACCNT NAME CLASS AMOUNT MEMO)
mid_header = %w(!SPL DATE ACCNT NAME AMOUNT MEMO)
bot_header = %w(!ENDTRNS)

headers = [top_header, mid_header, bot_header]

file_contents = []
CSV.foreach("EXPORT.csv") do |row|
	file_contents << row
end

File.open("Example.iif", "w") { |io|
	headers.each do |header|
		io.write(header.join("\t"))
		io.write("\n")
	end
}