# 
# This file defines the behavior of all liquidity providers (as in an interface) plus specific
# implementations of this behavior for the different types of providers
#

require_relative 'rest_trade_service_wrapper'
require_relative 'fix_trade_service_wrapper'

class LiquidityProvider

    def initialize()
    end

    def issue_market_trade(order)
    end

end

# liquidity provider C uses a REST service to execute the trade order
class LiquidityProviderC < LiquidityProvider

    def initialize(rest_trade_service)
        @rest_trade_service = rest_trade_service
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

          if response == nil
            raise 'REST trade service did not respond.'
          elsif response.code.to_i == 200
            handle_rest_trade_confirmation(response)
          else
            raise 'REST order execution failed.'
          end
    end

    def handle_rest_trade_confirmation(rest_trade_confirmation)
        # trade confirmation will be persisted in db
    end
end

# definition of liquidity providers based on the FIX protocol
class LiquidityProviderFix < LiquidityProvider

    def initialize(fix_trade_service)
        @fix_trade_service = fix_trade_service
    end

    def issue_market_trade(order)

        check_fix_service_status()

        send_order_to_fix_service(order)

        response = wait_for_fix_response(order.order_id)
        handle_fix_trade_confirmation(response)
    end

    def send_order_to_fix_service(order)
        # it will call the actual fix service wrapper with the required body format
    end

    def handle_fix_trade_confirmation(fix_trade_confirmation)
        # trade confirmation will be persisted in db
    end

    def wait_for_fix_response(order_id)
        # blocking read waiting for a redis key where trade confirmation is stored
    end
    
    def check_fix_service_status()
        # it will throw an Exception if there is no connectivity with
        # this LP fix service  
    end
end

class LiquidityProviderA < LiquidityProviderFix

    def send_order_to_fix_service(order)
        @fix_trade_service.send_to_redis(
            :lp_acme_provider_queue, 
            'fix:order:execute',
            clOrdID: order.order_id, 
            side: order.side, 
            orderQty: order.size, 
            ccy1: order.currency, 
            ccy2: order.counter_currency,
            value_date: order.date, 
            price: order.price
          )
    end
end

class LiquidityProviderB < LiquidityProviderFix
    
    def send_order_to_fix_service(order)
        @fix_trade_service.send_to_redis(
            :lp_wall_street_provider_queue, 
            'fix:executetrade',
            ordType: 'D',
            clOrdID: order.order_id, 
            side: order.side,
            orderQty: order.size,
            currency_1: order.currency,
            currency_2: order.counter_currency,
            futSettDate: order.date,
            price: order.price
          )
    end
end
