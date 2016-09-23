#gem install riif
require 'csv'

puts "Initial Commit!"
puts "This is what your CSV CONTAINS!:"
gets.chomp
CSV.foreach("EXPORT.csv") do |row|
	puts row.inspect
end
gets.chomp