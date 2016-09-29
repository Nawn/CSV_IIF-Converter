module Templates
	class Template
		attr_reader :desc
	end

	class Noah < Template
		def initialize
			@desc = "Date | Description | Check # <Empty=OK> | Debit | Credit"
		end
	end
end