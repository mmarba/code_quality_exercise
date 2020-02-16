#
# This service provides a liquidity provider to which an order needs to be sent
# based on some business rules.
#

require_relative 'liquidity_provider.rb'
require_relative 'money_helper.rb'

class LiquidityProviderRoutingService

    def initialize(rest_trade_service, fix_trade_service)
      @rest_trade_service = rest_trade_service
      @fix_trade_service = fix_trade_service
    end
    
    # applies business rules to determine proper liquidity provider for given order
    def determine_liquidity_provider(order)
        amount = MoneyHelper.amount_in_usd(order.size, order.currency)
        if amount < 10_000.to_money(USD)
            liquidity_provider = LiquidityProviderC.new(@rest_trade_service)
          elsif (amount >= 10_000.to_money(USD) && amount < 100_000.to_money(USD))
            liquidity_provider = LiquidityProviderB.new(@fix_trade_service)
          else
            liquidity_provider = LiquidityProviderA.new(@fix_trade_service)
          end
    end
end