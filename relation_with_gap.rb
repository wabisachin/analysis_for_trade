#ギャップアップ(ギャップダウン)の順張りエントリー期待値

require 'csv'
require './module/analysis_tool'
# CSVデータを代入
data_name =  "CSV/N225_2015_2019.csv"
table =  CSV.table(data_name)

#初期値の設定
count = table.count
total_profit = 0
total_profit_rate =  0
total_profit_buy = 0
total_profit_sell = 0
total_profit_win_buy =  0
total_profit_lose_buy =  0
total_profit_win_sell =  0
total_profit_lose_sell =  0
max_return_buy = 0
max_return_sell = 0
max_loss_buy = 0
max_loss_sell = 0
count_all =  0
count_buy = 0
count_sell = 0
count_buy_win = 0
count_sell_win =  0
trade_list =  []
puts 'ギャップ値幅を何円以上に設定しますか'
gap_width =  gets.to_i

#繰り返し処理
(count-1).times do |i|
    data_today =  table[i+1]
    data_yesterday =  table[i]
    if gap_up?(data_today,data_yesterday,gap_width)
        # ギャップアップ時は買いエントリー
        trade_profit = data_today[:close] - data_today[:open]

        if trade_profit > 0
            count_buy_win+=1
            total_profit_win_buy += trade_profit
        else 
            total_profit_lose_buy += trade_profit
        end

        max_return_buy = trade_profit if max_return_buy < trade_profit
        max_loss_buy = trade_profit if trade_profit < max_loss_buy 
        trade_profit_rate = trade_profit/data_today[:open].to_f*100
        total_profit_buy+=trade_profit
        count_buy += 1
        count_all +=1
        total_profit += trade_profit
        total_profit_rate += trade_profit_rate
        # puts data_today
        # puts total_profit
    elsif gap_down?(data_today,data_yesterday,gap_width)
        # ギャップダウン時は売りエントリー
        trade_profit =  data_today[:open] - data_today[:close]

        if trade_profit > 0
            count_sell_win+=1
            total_profit_win_sell += trade_profit
        else 
            total_profit_lose_sell += trade_profit
        end

        max_return_sell = trade_profit if max_return_sell < trade_profit
        max_loss_sell = trade_profit if trade_profit < max_loss_sell 
        trade_profit_rate = trade_profit/data_today[:open].to_f*100
        total_profit_sell+=trade_profit
        count_sell += 1
        count_all +=1
        total_profit += trade_profit
        total_profit_rate += trade_profit_rate
        # puts data_today
        # puts total_profit
        
    end

    trade_list.push data_today
    
end

# これまでのカウンティングから買いエントリー、売りエントリーそれぞれの合計負け回数を定義
count_buy_lose =  count_buy-count_buy_win
count_sell_lose =  count_sell-count_sell_win

puts "設定エントリー条件: ギャップ幅: #{gap_width}円"
puts "全営業日: #{count}"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<全期間エントリーのデータ集計結果>"
puts "エントリー日数: #{count_all}日"
puts "期間合計損益: #{total_profit}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit/count_all}円"
puts "１トレードの平均勝率: #{(count_buy_win+count_sell_win)/count_all.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{(total_profit_win_buy+total_profit_win_sell)/(count_buy_win+count_sell_win)}"
puts "１トレードあたりの平均負け値幅: #{(total_profit_lose_buy+total_profit_lose_sell)/(count_buy_lose+count_sell_lose)}"
puts "割合ベースの期間合計損益: #{total_profit_rate}%"
puts "割合ベースの１トレードあたりの平均値幅: #{total_profit_rate/count_all}%"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<買いエントリーの内訳>"
puts "エントリ-日数: #{count_buy}日"
puts "期間合計損益: #{total_profit_buy}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit_buy/count_buy}円"
puts "１トレードの平均勝率: #{count_buy_win/count_buy.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{total_profit_win_buy/count_buy_win}"
puts "１トレードあたりの平均負け値幅: #{total_profit_lose_buy/(count_buy_lose)}"
puts "最大利益幅: #{max_return_buy}円"
puts "最大損失幅: #{max_loss_buy}円"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<売りエントリーの内訳>"
puts "エントリー日数: #{count_sell}日"
puts "期間合計損益: #{total_profit_sell}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit_sell/count_sell}円"
puts "１トレードの平均勝率: #{count_sell_win/count_sell.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{total_profit_win_sell/count_sell_win}"
puts "１トレードあたりの平均負け値幅: #{total_profit_lose_sell/(count_sell_lose)}"
puts "最大利益幅: #{max_return_sell}円"
puts "最大損失幅: #{max_loss_sell}円"

# count_buy_lose =  count_buy-count_buy_win
# count_sell_lose =  count_sell-count_sell_win
