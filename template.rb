module Templates
	class Template
		attr_reader :desc

		#Checks for Dates
		def date?(input_string)
			input_string =~ /\d{1,4}\/\d{1,2}\/\d{1,4}/
		end

		#Checks for values surrounded by Parenthesis
		def neg_amount?(input_string)
			input_string =~ /\(\d+\.?\d*\)/
		end

		#Checks for bare amounts
		def pos_amount?(input_string)
			input_string =~ /\d+\.?\d*/
		end


		def present?(input_string)
			!input_string.to_s.empty?
		end
	end

	class Noah < Template
		def initialize
			@desc = "Date(mm/dd/yyyy) | Description | Check # <Empty=OK> | Debit | Credit"
		end

		def valid_row?(input_array)
			date?(input_array[0]) && present?(input_array[1]) && (neg_amount?(input_array[3]) || !present?(input_array[3])) && (pos_amount?(input_array[4]) || !present?(input_array[4]))
		end
	end
end