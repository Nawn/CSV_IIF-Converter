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