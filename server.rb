require 'sinatra'
require 'cryptoexchange'
require 'sinatra/json'
require 'json'
set :port, 5056
set :json_content_type, :js
coins = ["BNB", "0xBTC", "RLC", "GEN", "REQ", "DAI", "BAT", "REP", "STORM", "DENT", "KNC", "ZRX", "USDC", "SNT", "PAX", "PST"]
def get_bid_ask(pair,order_book)
    if order_book.bids[0].nil?
        return nil;
    end
    bid = BigDecimal.new(order_book.bids[0].price,8).to_s('8F')
    ask = BigDecimal.new(order_book.asks[0].price,8).to_s('8F')
    result = {'base' => pair.base, 'target' => pair.target, 'bid' => bid, 'ask' => ask}
    return result;
end
def get_bid_ask_for_coin(coin,pairs,client)
    pairs.each {|pair|
       if (pair.base == coin && pair.target == "ETH")
           order_book = client.order_book(pair)
           return get_bid_ask(pair,order_book)
       end
    }
    return false;
end 
client = Cryptoexchange::Client.new
bipairs = client.pairs('binance')
biboxpairs = client.pairs('bibox')
pairs = [['binance',bipairs],['bibox',biboxpairs]]
json_results = []
results = []
json_lastLoad = 0
lastLoad = 0
get '/json' do
    n = Time.now
    if (n-json_lastLoad).to_i > 60
      json_lastLoad = n
      json_results = []
      pairs.each {|expair|
        coins.each {|coin|
          result = get_bid_ask_for_coin(coin,expair[1],client)
          if result
            json_results.push(result)
          end
        }
      }
    end
    json(json_results, :encoder => :to_json, :content_type => :js)
end
get '/' do
    n = Time.now
    if (n-lastLoad).to_i > 60
      lastLoad = n
      result = "<table>"
      coins.each {|coin|
        pairs.each {|expair|
         ba = get_bid_ask_for_coin(coin,expair[1],client)
         if ba
             result += "<tr><td>"+expair[0]+"</td><td>"+ba["base"]+"/"+ba["target"]+"</td></tr>\n"
             result += "<tr><td>bid</td>"+"<td>"+ba["bid"]+"</td></tr>\n"
             result += "<tr><td>ask</td>"+"<td>"+ba["ask"]+"</td></tr>\n"
         end
        }
      }
      result += "</table>"
    end
    result
end
