#
# This service provides an interface for order routing AND trade execution  
# using different avaiable Liquidity Providers (aka "LPs") using two different
# protocols: REST (http) and FIX (Financial Information eXchange) 

require_relative 'liquidity_provider_routing_service.rb'
require_relative 'trade_order.rb'

class TradeExecutionService
    
  def initialize
    @liquidity_provider_routing_service = LiquidityProviderRoutingService.new()
  end

  def execute_order(side, size, currency, counter_currency, date, price, order_id)

    trade_order = TradeOrder.new(side, size, currency, counter_currency, date, price, order_id)

    liquidity_provider = @liquidity_provider_routing_service.determine_liquidity_provider(trade_order)

    liquidity_provider.issue_market_trade(trade_order);
  
  rescue
    File.open('./errors.log', 'a') do |f|
      f.puts "Execution of #{order_id} failed."
    end
  end


  # FIX is a protocol used to execute market orders against a Liquidity Provider
  def issue_fix_market_trade(side, size, currency, counter_currency, date, price, order_id, lp)
    check_fix_service_status(lp)
    if lp == LIQUIDITY_PROVIDER_A
      send_to_redis(
        :lp_acme_provider_queue, 
        'fix:order:execute',
        clOrdID: order_id, 
        side: side, 
        orderQty: size, 
        ccy1: currency, 
        ccy2: counter_currency,
        value_date: date, 
        price: price
      )
    else 
      send_to_redis(
        :lp_wall_street_provider_queue, 
        'fix:executetrade',
        ordType: 'D',
        clOrdID: order_id, 
        side: side,
        orderQty: size,
        currency_1: currency,
        currency_2: counter_currency,
        futSettDate: date,
        price: price
      )
    end

    response = wait_for_fix_response(order_id, lp)
    handle_fix_trade_confirmation(response)
  end

  def send_to_redis(queue, command, payload = nil)
    redis_msg = payload == nil ? command : "#{command}::#{JSON.dump(payload)}" 
    @connection.rpush queue, redis_msg
  end

end