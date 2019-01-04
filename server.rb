require 'sinatra'
require 'cryptoexchange'
set :port, 5056
client = Cryptoexchange::Client.new
get '/' do
    result = "<table>"
    pairs = client.pairs('binance')
    coins = ["BAT","STORM","KNC","REP","ZRX","REQ","DENT","DAI","RLC","DNT","SPN","BNB","BNTY"]
    pairs.each {|pair|
      if (coins.include?pair.base) && (pair.target == "ETH")
       ticker = client.ticker(pair)
       order_book = client.order_book(pair)
       #puts order_book.bids[0].instance_variables
       result += "<tr><td></td><td>"+pair.base+"/"+pair.target+"</td></tr>\n"
       result += "<tr><td>bid</td>"+"<td>"+order_book.bids[0].price.to_s('8F')+"</td></tr>\n"
       result += "<tr><td>ask</td>"+"<td>"+order_book.asks[0].price.to_s('8F')+"</td></tr>\n"
      end
    }
    result += "</table>"
    result
end
