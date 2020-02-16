#
# Specs for the TradeExecutionService.
# They verify that the order is routed to the proper liquidity provider.
# The whole workflow of executing an order is performed with the exception of the
# call to the REST or FIX external services, that are mocked to avoid dependencies external to the system under test.
#

require 'rspec'
require_relative '../trade_execution_service.rb'
require_relative '../rest_trade_service_wrapper.rb'
require_relative '../fix_trade_service_wrapper.rb'

describe TradeExecutionService do
    
    describe "#execute_order" do

        let(:rest_trade_svc) {instance_double(RESTTradeServiceWrapper)}
        let(:fix_trade_svc) {instance_double(FIXTradeServiceWrapper)}
        let(:execution_service) {TradeExecutionService.new(rest_trade_svc, fix_trade_svc)}
        let(:order_side) {'buy'}
        let(:order_cur) {'USD'}
        let(:order_c_cur) {'EUR'}
        let(:order_date) {'11/12/2018'}
        let(:order_price) {'1.1345'}

        context "when amount is less than 10K USD" do
            it "routes order to liquidity provider C" do
                expect(rest_trade_svc).to receive(:post_trade_request)
                execution_service.execute_order('buy', 8000, 'USD', 'EUR','11/12/2018', '1.1345', 'X-8000')
            end
        end

        context "when amount equals boundary value 9999 USD" do
            it "routes order to liquidity provider C" do
                expect(rest_trade_svc).to receive(:post_trade_request)
                execution_service.execute_order('buy', 9999, 'USD', 'EUR','11/12/2018', '1.1345', 'X-9999')
            end
        end

        context "when amount equals boundary value 10K USD" do
            it "routes order to liquidity provider B" do
                expect(fix_trade_svc).to receive(:send_to_redis).
                    with(:lp_wall_street_provider_queue,            
                    'fix:executetrade', ordType: 'D', clOrdID:  'X-10000', side: order_side, orderQty: 10000, 
                    currency_1: order_cur, currency_2: order_c_cur, futSettDate: order_date, price: order_price)

                execution_service.execute_order(order_side, 10000, order_cur, order_c_cur, order_date, order_price, 'X-10000')
            end
        end

        context "when amount is bigger than 10K USD and less than 100K USD" do
            it "routes order to liquidity provider B" do
                expect(fix_trade_svc).to receive(:send_to_redis).
                    with(:lp_wall_street_provider_queue,            
                    'fix:executetrade', ordType: 'D', clOrdID:  'X-77001', side: order_side, orderQty: 77001, 
                    currency_1: order_cur, currency_2: order_c_cur, futSettDate: order_date, price: order_price)

                execution_service.execute_order(order_side, 77001, order_cur, order_c_cur, order_date, order_price, 'X-77001')            
            end
        end

        context "when amount equals boundary value 99999 USD" do
            it "routes order to liquidity provider B" do
                expect(fix_trade_svc).to receive(:send_to_redis).
                    with(:lp_wall_street_provider_queue,            
                    'fix:executetrade', ordType: 'D', clOrdID:  'X-99999', side: order_side, orderQty: 99999, 
                    currency_1: order_cur, currency_2: order_c_cur, futSettDate: order_date, price: order_price)

                execution_service.execute_order(order_side, 99999, order_cur, order_c_cur, order_date, order_price, 'X-99999')           
            end
        end

        context "when amount equals boundary value 100000 USD" do
            it "routes order to liquidity provider A" do
                expect(fix_trade_svc).to receive(:send_to_redis).
                    with(:lp_acme_provider_queue, 
                    'fix:order:execute', clOrdID: 'X-100000', side: order_side, orderQty: 100000, 
                    ccy1: order_cur, ccy2: order_c_cur, value_date: order_date, price: order_price)

                execution_service.execute_order(order_side, 100000, order_cur, order_c_cur, order_date, order_price, 'X-100000')           
            end
        end

        context "when amount is bigger than 100000 USD" do
            it "routes order to liquidity provider A" do
                expect(fix_trade_svc).to receive(:send_to_redis).
                    with(:lp_acme_provider_queue, 
                    'fix:order:execute', clOrdID: 'X-200000', side: order_side, orderQty: 200000, 
                    ccy1: order_cur, ccy2: order_c_cur, value_date: order_date, price: order_price)

                execution_service.execute_order(order_side, 200000, order_cur, order_c_cur, order_date, order_price, 'X-200000')           
            end
        end
        
    end
end