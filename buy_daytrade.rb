require 'csv'

#毎日寄り付き買って引けで売った時の期待値

table = CSV.table('N225_all_time.csv')
count_all =  table.count
total_profit = 0

count_all.times do |i|
    profit = table[i][:close]-table[i][:open]
    total_profit += profit
end

puts "トータル取引回数 : #{count_all}"
puts "期間トータル収益 : #{total_profit}円"
puts "一回あたりの収益期待値 : #{total_profit/count_all}円"