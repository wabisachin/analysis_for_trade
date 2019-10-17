#大陽線(大陰線)全返し後,数日間ポジション保有
#銘柄毎の繰り返し処理のために関数化
require 'csv'
require './module/analysis_tool'

def holding_days_after_full_returned(stock_code)
    # 選択されたCSVデータをtable型のデータに変換
    data_name =  "CSV/N225/#{stock_code}_2011_2019.CSV"
    table =  CSV.table(data_name)
    count = table.count #検証期間合計日数

    #初期値の設定
    total_profit = 0  #期間内トータル損益
    total_profit_rate =  0 #期間内トータル損益(割合ベース)
    total_profit_buy = 0 #買いエントリー合計損益
    total_profit_sell = 0 #売りエントリー合計損益
    total_profit_win_buy =  0 #買いエントリーの勝ち額の総和
    total_profit_lose_buy =  0 #買いエントリーの負け額の総和
    total_profit_win_sell =  0 #売りエントリーの勝ち額の総和
    total_profit_lose_sell =  0 #売りエントリーの負け額の総和
    max_return_buy = 0 #買いエントリーの最大勝ち額
    max_return_sell = 0 #売りエントリーの最大勝ち額
    max_loss_buy = 0 #買いエントリーの最大負け額
    max_loss_sell = 0 #売りエントリーの最大負け額
    count_all =  0 #期間内のトレード合計日数
    count_buy = 0 #期間内の買いエントリーの合計日数
    count_sell = 0#期間内の売りエントリーの合計日数
    count_buy_win = 0 #期間内の買いエントリーの勝ち日数
    count_sell_win =  0 #期間内の売りエントリーの勝ち日数
    trade_list =  [] #トレード日のohlcリスト

    #検証する初期条件の設定(ユーザー入力値)
    puts '前日終値からのギャップ値幅を前日のローソク足の長さ1に対して何パーセント以上に設定しますか' #100パーセント以上で大陽線全返しとなる。
    # rate_in_gap_for_sticklength =  gets.to_f
    rate_in_gap_for_sticklength =  1
    puts '前日ローソク足の最低長さを前日の大引価格を１として何パーセント以上に設定しますか' #例えば価格が500円の銘柄に対して10%を設定すれば50円以上のギャップアップ。
    rate_in_sticklength_for_price =  gets.to_f
    # rate_in_sticklength_for_price =  gets.to_f
    puts '前日ローソク足の実体部分の長さを前日ローソク足のの長さ１に対して何パーセント以上に設定しますか(髭が長い時を除外する)'
    # rate_in_entity_for_sticklength =  gets.to_f
    rate_in_entity_for_sticklength =  0.5
    puts '何日間ポジションを保有しますか(手仕舞いは大引に行われる)'
    # days_in_holding = gets.to_i
    days_in_holding = 3


    #繰り返し処理
    (count-(days_in_holding-1)-1).times do |i|
        data_today =  table[i+1]
        data_yesterday =  table[i]
        # length_yesterday =  data_yesterday[:high]-data_yesterday[:low]
        closed_price_yesterday =  data_yesterday[:close]
        next unless completed_chart?(data_yesterday, closed_price_yesterday*rate_in_sticklength_for_price, rate_in_entity_for_sticklength)
        #前日陽線と陰線の場合で条件分岐
        if white_stick?(data_yesterday)
            next if !gap_down_for_sticklength?(data_today,data_yesterday,rate_in_gap_for_sticklength)
            # ギャップダウン時は売りエントリー
            data_for_position_closed_day =  table[i+days_in_holding]
            trade_profit =  data_today[:open] - data_for_position_closed_day[:close]

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
            puts data_today
            puts total_profit
            
        else
            next if !gap_up_for_sticklength?(data_today,data_yesterday,rate_in_gap_for_sticklength)
            # ギャップアップ時は買いエントリー
            data_for_position_closed_day = table[i+days_in_holding]
            trade_profit = data_for_position_closed_day[:close] - data_today[:open]

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
            puts data_today
            puts total_profit
            
        end
        
    end

    # これまでのカウンティングから買いエントリー、売りエントリーそれぞれの合計負け回数を定義
    count_buy_lose =  count_buy-count_buy_win
    count_sell_lose =  count_sell-count_sell_win

    puts "=====エラー確認====="
    puts "エラーがあればここで確認"
    puts count_all
    puts "=========="
    puts "検証した銘柄コード： #{stock_code}"
    puts "設定したエントリー条件"
    puts "期間中営業日数: #{count}"
    puts "前日からのギャップ幅の最低割合: #{rate_in_gap_for_sticklength}"
    puts "ローソク足の最低幅の割合: #{rate_in_sticklength_for_price}"
    puts "ローソク足の実体の最低割合: #{rate_in_entity_for_sticklength}"
    puts "ポジション保有日数: #{days_in_holding}"

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
end

