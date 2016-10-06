module Templates
	class Template
		attr_reader :desc, :config_name, :temp_header, :display_name

		#Checks for Dates
		def date?(input_string)
			input_string =~ /\d{1,4}\/\d{1,2}\/\d{1,4}/
		end
    
    def convert_neg(input_string)
      raise ArgumentError.new("Input must be string") unless input_string.is_a? String
      raise ArgumentError.new("Input must begin with \'-\'") unless input_string[0] == "-"
      
      new_string = input_string[]
    end

		#Checks for values surrounded by Parenthesis
		def neg_amount?(input_string)
      input_string = input_string.to_s
      #If it starts with - rather than (), then check without the parenthesis
      input_string[0] == "-" ? pos_amount?(input_string[1..-1]) : input_string =~ /\(\d+\.?\d*\)/
		end

		def convert_neg(input_string)
			if input_string[0] == "-"
				return input_string.to_i
			elsif input_string[0] == "("
				return input_string[1..-2].to_i * -1
			else
				raise ArgumentError.new("Error, unexpected #{input_string[0]}: expecting \'-\' or \'(\'")
			end
		end

		def load_rules
			File.readlines("config/#{@config_name}", "\n")
		end

		#Checks for bare amounts
		def pos_amount?(input_string)
			input_string =~ /^\d+\.?\d*$/
		end

		#Ensures that a field is either Nil or an Empty string.
		def present?(input_string)
			!input_string.to_s.empty?
		end

		def self.default
			top_row = %w(!TRNS DATE ACCNT NAME CLASS AMOUNT MEMO DOCNUM)
			mid_row = %w(!SPL DATE ACCNT NAME AMOUNT MEMO DOCNUM)
			bot_row = %w(!ENDTRNS)
			[top_row, mid_row, bot_row]
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
			@temp_header = %w(Date Description Check# DebitAmount CreditAmount <nil> Name Account)
			@display_name = "BBVA Compass - Noah's Boytique"
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

			rules = load_rules.map { |rule| rule.split("~").map() {|indiv_rule| indiv_rule.split("!")}}
			#For rules: 
			#0,0 will get me the item to search in Description
			#1,0 will get me the name to place it under in QB
			#1,1.chomp will get me the accnt to place it under

			#For row/idx:
			#idx will tell you which row in input_array this is
			#row will provide a 6-size array of transaction data
			#Description will be in row[1]
			#We will set row[6]=name row[7]=accnt

			processed = input_array.clone

			rules.each do |rule|
				processed.each_with_index do |row, idx|
					if row[1].downcase.include? rule[0][0].downcase
						row << rule[1][0] << rule[1][1].chomp
					end
				end
			end

			processed
		end

		#Returns an array ready to be converted by CSV lib to Tab-Delim
		def generate(input_array)
			#Guide: input_array contains (n) rows of Transactions
			#In each transaction array, there is TRNS data.
			#For Noah: 
			# trns[0]: date
			# trns[1]: desc
			# trns[2]: check#? Probably empty
			# trns[3]: Debit Amount, it means it's suppose to be negative
			#  Typically Debits
			# trns[4]: Credit Amount, supposed to be positive
			#  Typically empty, but there are Credits
			# trns[5]: Empty. Idk what goes there. It's just empty on import
			# trns[6]: If not filtered, NIL, if filtered, String=Name
			# trns[7]: "If not..", if filtered, String=Accnt
			return_array = []

			input_array.each do |trns|

				date = trns[0]
				account = trns[7]
				name = trns[6]
				debit = trns[3]
				credit = trns[4]
				class_var = ''
				amount = 0
				check_num = trns[2]

				#trns[3], trns[4] are the values I'm gonna check to 
				#see how I'm going to do this.
				if present?(debit)
					if debit[0] == "-"
						amount = debit.to_i
					elsif debit[0] == "("
						amount = debit[1..-2].to_i * -1
					else
						raise ArgumentError.new("Error, unexpected #{debit[0]}: expecting \'-\' or \'(\'")
					end
				elsif present?(credit)
					amount = credit.to_i
				else
					puts "ERROR! Both Credit and Debit field are empty"
				end

				memo = trns[1]

				return_array << ["TRNS", date.to_s, account.to_s, name.to_s, '', amount.to_s, memo.to_s]
				return_array << ["SPL", date.to_s, account.to_s, name.to_s, (amount.to_i * -1).to_s, memo.to_s]
				return_array << ["ENDTRNS"]
			end

			Template.default.reverse.each do |array|
				return_array.unshift(array)
			end

			return_array
		end
	end
end