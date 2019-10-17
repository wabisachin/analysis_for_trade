# 大陽線(大陰線)全返し
require './holding_days_after_full_returned.rb'

#./CSV/N225ディレクトリ内にあるファイル一覧を取得
stock_codes = get_csv_data('./CSV/N225')[0]
stock_files = get_csv_data('./CSV/N225')[1]

#スタート時の資産の設定(単位：万年)
initial_assets = 100
#初期値の設定
total_profit = 0 #期間内トータル損益
total_profit_rate = 0 #期間内トータル損益(割合ベース)
total_profit_buy = 0 #買いエントリー合計損益
total_profit_sell = 0 #売りエントリー合計損益
total_profit_win_buy = 0 #買いエントリーの勝ち額の総和
total_profit_lose_buy = 0 #買いエントリーの負け額の総和
total_profit_win_sell = 0 #売りエントリーの勝ち額の総和
total_profit_lose_sell = 0 #売りエントリーの負け額の総和
max_return_buy = 0 #買いエントリーの最大勝ち額
max_return_sell = 0 #売りエントリーの最大勝ち額
max_loss_buy = 0 #買いエントリーの最大負け額
max_loss_sell = 0 #売りエントリーの最大負け額
total_count_all =  0 #期間内のトレード合計日数
total_count_buy = 0 #期間内の買いエントリーの合計日数
total_count_sell = 0#期間内の売りエントリーの合計日数
total_count_buy_win = 0 #期間内の買いエントリーの勝ち日数
total_count_sell_win = 0 #期間内の売りエントリーの勝ち日数

# trade_list =  [] #トレード日のohlcリスト
selected_codes = []# 検証したい銘柄のコードを保持する配列
data_result = {} #検証結果データを保持するハッシュ
trade_data = [] #全トレードの取引結果を代入する用の変数



# 検証したいデータの選択
# puts "検証したい銘柄を以下から選択してください(全ての銘柄を選択する場合は『all』)"
# print stock_codes
# puts ""
while true do
    puts "検証したい銘柄を以下から選択してください(全ての銘柄を選択する場合は『all』。選択を終了する場合は『q』)"
    selected_code = gets.chomp

    break if selected_code == "q"
    # selected_codes.push(selected_code)
    
    if selected_code ==  "all"
        selected_codes = stock_codes
        break
    end

    unless stock_codes.include?(selected_code)
        puts "一致する銘柄がありません。正しい銘柄コードを入力してください"
        next
    end
    
    selected_codes.push(selected_code)
end

print selected_codes
puts ""

#選択された銘柄に対して手法実行ファイルを呼び出し、繰り返し処理
if selected_codes.include?("all")
    stock_codes.each do |code|
        result = holding_days_after_full_returned(code)[:result]
        data_result[code] = result
    end
else
    selected_codes.each do |code|
        result = holding_days_after_full_returned(code)
        data_result[code] = result
    end 
end

# puts data_result
 
# puts data_result["7203"]
# puts selected_codes

selected_codes.each do |code|
    #選択された全ての銘柄の結果を合算して変数に格納
    total_profit += data_result[code][:result][:profit]
    total_profit_rate += data_result[code][:result][:profit_rate]
    total_profit_buy += data_result[code][:result][:profit_buy]
    total_profit_sell += data_result[code][:result][:profit_sell]
    total_profit_win_buy += data_result[code][:result][:profit_win_buy]
    total_profit_lose_buy += data_result[code][:result][:profit_lose_buy]
    total_profit_win_sell += data_result[code][:result][:profit_win_sell]
    total_profit_lose_sell += data_result[code][:result][:profit_lose_sell]
    max_return_buy += data_result[code][:result][:max_return_buy]
    max_return_sell += data_result[code][:result][:max_return_sell]
    max_loss_buy += data_result[code][:result][:max_loss_buy]
    max_loss_sell += data_result[code][:result][:max_loss_sell]
    total_count_all += data_result[code][:result][:count_all]
    total_count_buy += data_result[code][:result][:count_buy]
    total_count_sell += data_result[code][:result][:count_sell]
    total_count_buy_win += data_result[code][:result][:count_buy_win]
    total_count_sell_win += data_result[code][:result][:count_sell_win]
    #全トレードの収支を変数に格納。この変数を使って資産推移データを作成。
    trades =  data_result[code][:trades]
    trades.each do |trade|
        #もし2月9日、2月16日なら除外
        #next if trade[:date] == Date.new(2016,2,9) or trade[:date] == Date.new(2016,2,15)
        trade_data.push trade
    end
    # puts trade_data
    #トレード結果を日付順でsort
    trade_data.sort!{|x,y| x[:date] <=> y[:date]}
    # puts trade_data
    
end
# puts trade_data[0][:date].class

puts trade_data
#日付をキーに、その日に行われた全トレードの結果を値にしたハッシュを作成
data_group_by_days = {}
data_group_by_days = trade_data.group_by{|v| v[:date]}
puts data_group_by_days
# puts data_group_by_days[Date.new(2011,11,10)].count
daily_score =  {}
assets = initial_assets
data_group_by_days.each do |date, trades|
    #日別の合計損益
    
    daily_total_profit = 0
    #その日のエントリー銘柄数
    count =  trades.count
    #一日の最大保有銘柄数
    max_count = 3
    #その日のトレード収益
    trades.each do |trade|
        lot = initial_assets*100/trade[:entry_price]
        if trade[:type] == "buy"
            profit = (trade[:exit_price]- trade[:entry_price])*lot/100.to_f #単位：万円なので100で割る
        else
            profit = (trade[:entry_price] - trade[:exit_price])*lot/100.to_f
        end
        daily_total_profit += profit
    end

    if count >= max_count
        profit_ave =  daily_total_profit/count.to_f
        daily_total_profit = profit_ave*max_count
    end
    daily_score[date] = {count: count, total_profit: daily_total_profit}

end
puts daily_score

daily_score.each do |k,v|
    assets += v[:total_profit]
    puts k, assets
end


#資金〇〇万円に対して資産がいくら増えたかのシミュレーション

# trade_data.each do |trade|
#     puts trade
#     # puts trade[:entry_price]
#     # puts initial_assets
#     lot = initial_assets*100/trade[:entry_price]
#     # puts lot
#     if trade[:type] == "buy"
#         profit = (trade[:exit_price]- trade[:entry_price])*lot/100.to_f #単位：万円なので100で割る
#     else
#         profit = (trade[:entry_price] - trade[:exit_price])*lot/100.to_f
#     end
#     assets += profit
#     puts profit
#     puts "#{assets}万円"
# end

total_count_buy_lose = total_count_buy- total_count_buy_win
total_count_sell_lose = total_count_sell- total_count_sell_win

puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<全期間エントリーのデータ集計結果>"
puts "エントリー日数: #{total_count_all}日"
puts "期間合計損益: #{total_profit}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit/total_count_all}円"
puts "１トレードの平均勝率: #{(total_count_buy_win+total_count_sell_win)/total_count_all.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{(total_profit_win_buy+total_profit_win_sell)/(total_count_buy_win+total_count_sell_win)}"
puts "１トレードあたりの平均負け値幅: #{(total_profit_lose_buy+total_profit_lose_sell)/(total_count_buy_lose+total_count_sell_lose)}"
puts "割合ベースの期間合計損益: #{total_profit_rate}%"
puts "割合ベースの１トレードあたりの平均値幅: #{total_profit_rate/total_count_all}%"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<買いエントリーの内訳>"
puts "エントリ-日数: #{total_count_buy}日"
puts "期間合計損益: #{total_profit_buy}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit_buy/total_count_buy}円"
puts "１トレードの平均勝率: #{total_count_buy_win/total_count_buy.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{total_profit_win_buy/total_count_buy_win}"
puts "１トレードあたりの平均負け値幅: #{total_profit_lose_buy/(total_count_buy_lose)}"
puts "最大利益幅: #{max_return_buy}円"
puts "最大損失幅: #{max_loss_buy}円"
puts "ーーーーーーーーーーーーーーーーーーーーーーーーーー"
puts "<売りエントリーの内訳>"
puts "エントリー日数: #{total_count_sell}日"
puts "期間合計損益: #{total_profit_sell}円"
puts "１トレードあたりの平均獲得値幅: #{total_profit_sell/total_count_sell}円"
puts "１トレードの平均勝率: #{total_count_sell_win/total_count_sell.to_f*100}%"
puts "１トレードあたりの平均勝ち値幅: #{total_profit_win_sell/total_count_sell_win}"
puts "１トレードあたりの平均負け値幅: #{total_profit_lose_sell/(total_count_sell_lose)}"
puts "最大利益幅: #{max_return_sell}円"
puts "最大損失幅: #{max_loss_sell}円"
