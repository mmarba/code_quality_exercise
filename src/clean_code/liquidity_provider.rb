# 
# This file defines the behavior of all liquidity providers (as in an interface) plus specific
# implementations of this behavior for the different types of providers
#
require_relative 'trade_order.rb'
require_relative 'rest_trade_service_wrapper'

class LiquidityProvider

    def initialize()
    end

    def issue_market_trade(order)
    end

end

class LiquidityProviderC < LiquidityProvider
    
    REST_TRADER_SERVICE_URL = 'http://lp_c_host/trade'

    def initialize()
        @rest_trade_service = RESTTradeServiceWrapper.new(REST_TRADER_SERVICE_URL)
    end

    def issue_market_trade(order)
        payload = {        
            order_type: 'market',
            order_id: order.order_id, 
            side: order.side, 
            order_qty: order.size, 
            ccy1: order.currency,
            ccy2: order.counter_currency,
            value_date: order.date, 
            price: order.price
          }
          json_payload = JSON.dump(payload)

          response = @rest_trade_service.post_trade_request(json_payload)

          if response.code.to_i == 200
            handle_rest_trade_confirmation(response)
          else
            raise 'REST order execution failed.'
          end
    end

    def handle_rest_trade_confirmation(rest_trade_confirmation)
        # trade confirmation will be persisted in db
    end
end

class LiquidityProviderFix < LiquidityProvider

    def handle_fix_trade_confirmation(fix_trade_confirmation)
        # trade confirmation will be persisted in db
    end

    def wait_for_fix_response(order_id, lp)
        # blocking read waiting for a redis key where trade confirmation is stored
    end
    
    def check_fix_service_status(lp)
        # it will throw an Exception if there is no connectivity with
        # this LP fix service  
    end
end

class LiquidityProviderA < LiquidityProviderFix
    def issue_market_trade(order)
    end
end

class LiquidityProviderB < LiquidityProviderFix
    def issue_market_trade(order)
    end
end
