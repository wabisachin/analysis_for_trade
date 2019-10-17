
#xlsファイル解析に使用するgem https://github.com/zdavatz/spreadsheet
#取得した株データcsvファイルのソース https://finance.yahoo.com/quote/%5EN225/history?period1=1565362800&period2=1570633200&interval=1d&filter=history&frequency=1d

# ※このファイルで扱うCSVファイルはdate,open,high,low,close,volumeのデータを持っている必要がある。もし持っていない場合、あらかじめCSVファイルを編成し直す

#窓開けの順張りエントリーでの期待値

require './module/analysis_tool.rb'
require 'spreadsheet'
require 'csv'

writeName = 'N225_result.xls'

if File.exist?(writeName)
    puts "同名のファイルが既に存在します"
    exit
end

writeBook = Spreadsheet::Workbook.new
data_name =  "CSV/4063_2011_2019.CSV"
table = CSV.table(data_name)
# 日足データのエクセル表示(writeSheet1)
writeSheet1 = writeBook.create_worksheet(name: '日足データ')
writeSheet1.row(0).push "date", "open", "high", "low", "close", "volume"
table.each_with_index do |row,i|
    writeSheet1.row(i+1).push row[:date], row[:open], row[:high], row[:low], row[:close], row[:volume]
end

# 窓開け翌日の解析(writeSheet2)
writeSheet2 = writeBook.create_worksheet(name: '窓空け順張りの期待値解析')


data_count = table.count
data_with_window = []
profit_list = []
total_profit_buy = 0
total_profit_sell = 0
total_profit = 0
max_return_buy = 0
max_return_sell = 0
max_loss_buy = 0
max_loss_sell = 0
count_buy = 0
count_sell = 0
count_buy_win = 0
count_sell_win =  0
puts '窓開けの値幅を何円以上に設定しますか'
window_width =  gets.to_i


(data_count-1).times do |i|
    data_today = table[i+1]
    data_yesterday = table[i]
    if gap_with_window?(data_today, data_yesterday, window_width)
        data_with_window.push data_today
        if higher_than_yesterday?(data_today, data_yesterday)
            count_buy+=1
            trade_profit = data_today[:close]-data_today[:open]
            # puts (trade_profit>0)
            count_buy_win+=1 if trade_profit>=0
            max_return_buy = trade_profit if max_return_buy < trade_profit
            max_loss_buy = trade_profit if trade_profit < max_loss_buy 
            total_profit_buy += trade_profit
        else 
            count_sell+=1
            trade_profit =  -(data_today[:close]-data_today[:open])
            count_sell_win+=1 if trade_profit >= 0
            max_return_sell = trade_profit if max_return_sell < trade_profit
            max_loss_sell = trade_profit if trade_profit < max_loss_sell 
            total_profit_sell += trade_profit
            
        end
        
        profit_list.push [trade_profit]
        total_profit += trade_profit
    end
end

# puts data_with_window

# puts profit_list

puts "エントリー日数は#{profit_list.count}日です"
puts "期間合計損益は#{total_profit}円幅です"
puts "１トレードあたりの平均値幅は#{total_profit/profit_list.count}円です"

puts "<買いエントリーの内訳>"
puts "買いエントリ-日数は#{count_buy}日です"
puts "買いエントリー時の平均勝率は#{count_buy_win/count_buy.to_f*100}%です"
puts "買いエントリーの期間合計損益は#{total_profit_buy}円です"
puts "買いエントリーの１トレードあたりの平均値幅は#{total_profit_buy/count_buy}"
puts "買いトレードの最大利益幅は#{max_return_buy}円です"
puts "買いトレードの最大損失幅は#{max_loss_buy}円です"

puts "<売りエントリーの内訳>"
puts "売りエントリー日数は#{count_sell}日です"
puts "売りエントリー時の平均勝率は#{count_sell_win/count_sell.to_f*100}%です"
puts "売りエントリーの期間合計損益は#{total_profit_sell}円です"
puts "売りエントリーの１トレードあたりの平均値幅は#{total_profit_sell/count_sell}"
puts "売りトレードの最大利益幅は#{max_return_sell}円です"
puts "売りトレードの最大損失幅は#{max_loss_sell}円です"

# writeBook.write(writeName)