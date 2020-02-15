#
# This service provides an interface for order routing AND trade execution  
# using different avaiable Liquidity Providers (aka "LPs") using two different
# protocols: REST (http) and FIX (Financial Information eXchange) 

require_relative 'liquidity_provider_routing_service.rb'
require_relative 'trade_order.rb'

class TradeExecutionService
    
  def initialize
  end

  def execute_order(side, size, currency, counter_currency, date, price, order_id)

    trade_order = TradeOrder.new(side, size, currency, counter_currency, date, price, order_id)

    liquidity_provider = LiquidityProviderRoutingService.determine_liquidity_provider(trade_order)

    liquidity_provider.issue_market_trade(trade_order);
  
#  rescue
#    File.open('./errors.log', 'a') do |f|
#      f.puts "Execution of #{order_id} failed."
#    end
  end
end