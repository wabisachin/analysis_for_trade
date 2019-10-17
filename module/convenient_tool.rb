# 分析ツール以外の一般的な便利な機能をまとめたツール

def get_csv_data(directory)
    stock_files=[]
    stock_codes =[]
    Dir.foreach(directory) do |file|
        next if file == '.' or file == '..'
        stock_files.push file
    end
    stock_files.each do |file|
        stock_code = file.slice(0..3)
        stock_codes.push stock_code
    end
    #配列[0]に銘柄コードを,配列[1]にファイル名を返す
    return [stock_codes,stock_files]
end