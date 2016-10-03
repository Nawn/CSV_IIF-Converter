module Templates
	class Template
		attr_reader :desc, :config_name

		#Checks for Dates
		def date?(input_string)
			input_string =~ /\d{1,4}\/\d{1,2}\/\d{1,4}/
		end

		#Checks for values surrounded by Parenthesis
		def neg_amount?(input_string)
			input_string =~ /\(\d+\.?\d*\)/
		end

		def load_rules
			File.readlines("config/#{@config_name}", "\n")
		end

		#Checks for bare amounts
		def pos_amount?(input_string)
			input_string =~ /\d+\.?\d*/
		end

		#Ensures that a field is either Nil or an Empty string.
		def present?(input_string)
			!input_string.to_s.empty?
		end

		def self.yn_continue(first_string)
			repeat = true

			until !repeat
				user_response = gets.chomp
				case user_response.downcase
				when 'y'
					puts "\n\nContinuing...\n\n"
					repeat = false
				when 'n'
					puts "\n\n#{first_string}\n\n"
					exit
				else
					puts "\n\nI'm sorry, I don't understand #{user_response}, please enter \'y\' or \'n\'\n\n"
				end
			end
		end
	end

	class Noah < Template
		def initialize
			@desc = "Date(mm/dd/yyyy) | Description | Check # <Empty=OK> | Debit | Credit"
			@config_name = "noah.txt"
		end

		def valid_row?(input_array)
			date?(input_array[0]) && present?(input_array[1]) && (neg_amount?(input_array[3]) || !present?(input_array[3])) && (pos_amount?(input_array[4]) || !present?(input_array[4]))
		end

		def filter(input_array)
			#The DSL for this method is <Description: search string>~<Designated Name>!<Designated Account>
			unless File.exist?("config/#{@config_name}")
				puts "\n\nWARNING: YOU DO NOT HAVE A COMPARISON FILE TITLED \'#{@config_name}\', CONTINUE ANYWAY? (No Changes Will Be made) [y/n]\n\n"
				
				Template.yn_continue("Please place a comparison file titled \'#{@config_name}\' in the \'config\' folder and try again! Thank you!")
				return input_array
			end

			rules = load_rules
			
			rules.each do |rule|
				puts "poopy rule: #{rule}"
			end
		end
	end
end