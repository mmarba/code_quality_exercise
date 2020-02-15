#
# This service provides a liquidity provider to which an order needs to be sent
# based on some business rules.
#

require_relative 'liquidity_provider.rb'
require_relative 'money_helper.rb'

class LiquidityProviderRoutingService

    def initialize()
    end
    
    # applies business rules to determine proper liquidity provider for given order
    def self.determine_liquidity_provider(order)
        amount = MoneyHelper.amount_in_usd(order.size, order.currency)
        if amount < 10_000.to_money(USD)
            liquidity_provider = LiquidityProviderC.new()
          elsif (amount >= 10_000.to_money(USD) && amount < 100_000.to_money(USD))
            liquidity_provider = LiquidityProviderB.new()
          else
            liquidity_provider = LiquidityProviderA.new()
          end
    end
end