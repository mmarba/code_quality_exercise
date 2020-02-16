#
# Example on the usage of the service. REST and FIX service wrappers are mocked in this example.
#

require_relative "trade_execution_service.rb"
require_relative "rest_trade_service_wrapper.rb"
require_relative "fix_trade_service_wrapper.rb"

rest_trade_service = MockedRESTTradeServiceWrapper.new('http://lp_c_host/trade')
fix_trade_service = MockedFIXTradeServiceWrapper.new('redis://localhost/')

execution_service = TradeExecutionService.new(rest_trade_service, fix_trade_service)
execution_service.execute_order('buy', 7000, 'USD', 'EUR', '11/12/2018', '1.1345', 'X-A213FFL')
