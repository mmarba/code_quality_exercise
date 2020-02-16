#
# Specs for the LiquidityProviderRoutingService.
# They verify that this provider returns the expected liquidity provider given an order.
#

require 'rspec'
require_relative '../liquidity_provider_routing_service.rb'
require_relative '../trade_order.rb'
require_relative '../liquidity_provider.rb'
require_relative '../rest_trade_service_wrapper.rb'
require_relative '../fix_trade_service_wrapper.rb'

describe LiquidityProviderRoutingService do
    
    describe "#determine_liquidity_provider" do

        let(:rest_trade_svc) {instance_double(RESTTradeServiceWrapper)}
        let(:fix_trade_svc) {instance_double(FIXTradeServiceWrapper)}
        let(:liquidity_provider_routing_service) {LiquidityProviderRoutingService.new(rest_trade_svc, fix_trade_svc)}
        let(:trade_order_less_than_10000) {TradeOrder.new('buy', 8000, 'USD', 'EUR','11/12/2018', '1.1345', 'X-8000')}
        let(:trade_order_9999) {TradeOrder.new('buy', 9999, 'USD', 'EUR','11/12/2018', '1.1345', 'X-9999')}
        let(:trade_order_10000) {TradeOrder.new('buy', 10000, 'USD', 'EUR','11/12/2018', '1.1345', 'X-10000')}
        let(:trade_order_bigger_than_10000_less_than_100000) {TradeOrder.new('buy', 77001, 'USD', 'EUR','11/12/2018', '1.1345', 'X-77001')}
        let(:trade_order_99999) {TradeOrder.new('buy', 99999, 'USD', 'EUR','11/12/2018', '1.1345', 'X-99999')}
        let(:trade_order_100000) {TradeOrder.new('buy', 100000, 'USD', 'EUR','11/12/2018', '1.1345', 'X-100000')}
        let(:trade_order_bigger_than_100000) {TradeOrder.new('buy', 200000, 'USD', 'EUR','11/12/2018', '1.1345', 'X-200000')}
 
        context "when amount is less than 10K USD" do
            it "routes order to liquidity provider C" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_less_than_10000)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderC)
            end
        end

        context "when amount equals boundary value 9999 USD" do
            it "routes order to liquidity provider C" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_9999)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderC)
            end
        end

        context "when amount equals boundary value 10K USD" do
            it "routes order to liquidity provider B" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_10000)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderB)
            end
        end

        context "when amount is bigger than 10K USD and less than 100K USD" do
            it "routes order to liquidity provider B" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_bigger_than_10000_less_than_100000)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderB)
            end
        end

        context "when amount equals boundary value 99999 USD" do
            it "routes order to liquidity provider B" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_99999)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderB)
            end
        end

        context "when amount equals boundary value 100000 USD" do
            it "routes order to liquidity provider A" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_100000)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderA)
            end
        end

        context "when amount is bigger than 100000 USD" do
            it "routes order to liquidity provider A" do
                liquidity_provider = liquidity_provider_routing_service.determine_liquidity_provider(trade_order_bigger_than_100000)
                expect(liquidity_provider).to be_instance_of(LiquidityProviderA)
            end
        end
    end
end