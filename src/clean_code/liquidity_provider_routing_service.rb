#
# This service provides a liquidity provider to which an order needs to be sent
# based on some business rules.
#

require_relative 'trade_order.rb'
require_relative 'liquidity_provider.rb'
require 'money'

class LiquidityProviderRoutingService

    def initialize()
    end
    
    # applies business rules to determine proper liquidity provider for given order
    def determine_liquidity_provider(order)
        amount = amount_in_usd(order.size, order.currency)
        if amount < 10_000
            liquidity_provider = LiquidityProviderC.new()
          elsif (amount >= 10_000 && amount < 100_000)
            liquidity_provider = LiquidityProviderB.new()
          else
            liquidity_provider = LiquidityProviderA.new()
          end
    end

    def amount_in_usd(size, currency)
        if currency == 'USD'
            return size
        else
            # this is just to cover the case where the currency is not USD
            return (size * 2)
        end
    end
end