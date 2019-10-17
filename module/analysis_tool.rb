#xlsファイル解析に使用するgem https://github.com/zdavatz/spreadsheet
require 'spreadsheet'
require 'csv'

def gap_with_window?(data_today,data_yesterday,distance=0)
    if data_today[:open] < (data_yesterday[:low]-distance) || (data_yesterday[:high]+distance) < data_today[:open] 
        return true
    else
        return false
    end
end

#前日の高値より寄り付き値が高いかどうかを返すメソッド
def higher_than_yesterday?(data_today, data_yesterday)
    return true if data_yesterday[:high] < data_today[:open]
end

# 大陰線、大陽線のように髭のないチャートかどうかの真偽を返すメソッド
def completed_chart?(data_ohlc,lowest_length=20, lowest_rate_entity=0.9)
    length = data_ohlc[:high]-data_ohlc[:low]
    length_entity = (data_ohlc[:close]-data_ohlc[:open]).abs
    rate_entity = length_entity/length.to_f

    if length >lowest_length && rate_entity > lowest_rate_entity 
        return true
    else
        return false
    end
end

# 陽線かどうかを返すメソッド
def white_stick?(data_ohlc)
    if data_ohlc[:close]>= data_ohlc[:open]
        return true 
    else
        return false
    end
end

#ギャップアップかどうかを返すメソッド(distanceは前日より何円以上上でGUとみなすか)
def gap_up?(data_ohlc_today, data_ohlc_yesterday,distance=0)
    return true if data_ohlc_today[:open] >= data_ohlc_yesterday[:close] + distance
end

#ギャップダウンかどうかを返すメソッド(distanceは前日より何円以上下でGDとみなすか)
def gap_down?(data_ohlc_today, data_ohlc_yesterday,distance=0)
    return true if data_ohlc_today[:open] <= data_ohlc_yesterday[:close] - distance
end

# ギャップアップかどうかを,前日引け値に対する割合ベースで判断してその結果を返すメソッド(rateは前日より何パーセント以上でGUとみなすか)
def gap_up_for_rate?(data_ohlc_today, data_ohlc_yesterday,rate=0)
    return true if (data_ohlc_today[:open]-data_ohlc_yesterday[:close])/data_ohlc_yesterday[:close].to_f > rate
end
# ギャップダウンかどうかを割合ベースで判断してその結果を返すメソッド(distaneは前日より何パーセント以下でGUとみなすか)
def gap_down_for_rate?(data_ohlc_today, data_ohlc_yesterday,rate=0)
    return true if (data_ohlc_yesterday[:close] - data_ohlc_today[:open])/data_ohlc_yesterday[:close].to_f > rate
end

#ギャップアップかどうかを、前日のローソク足(髭含む)の全体長に対する割合で判断して、その真偽を返すメソッド。(100パーセント以上なら大陽線、全返し)
def gap_up_for_sticklength?(data_ohlc_today,data_ohlc_yesterday,rate=0)
    return true if (data_ohlc_today[:open]-data_ohlc_yesterday[:close])/(data_ohlc_yesterday[:high]-data_ohlc_yesterday[:low]).to_f >  rate
    return false
end

#ギャップダウンかどうかを、前日のローソク足(髭含む)の全体長に対する割合で判断して、その真偽を返すメソッド。(100パーセント以上なら大陰線、全返し)
def gap_down_for_sticklength?(data_ohlc_today,data_ohlc_yesterday,rate=0)
    if (data_ohlc_yesterday[:close] - data_ohlc_today[:open])/(data_ohlc_yesterday[:high]-data_ohlc_yesterday[:low]).to_f >  rate
        return true
    else
        return false
    end
end

#ストップ高張り付きかどうかの真偽を返メソッド
def stop_price?(data_ohlc)
    open,high,low,close =  data_ohlc[:open], data_ohlc[:high], data_ohlc[:low], data_ohlc[:close]
    if open == high && open == low && open == close
        return true
    else
        return false
    end
end
