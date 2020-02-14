#
# This class is a wrapper that contains encapsulates the implementation
# of the access to a REST trade service
#

require 'httparty'

class RESTTradeServiceWrapper
    include HTTParty

    def initialize(trade_service_url)
        @trade_service_url = trade_service_url
    end

    def post_trade_request(json_payload)
        response = self.class.post(@trade_service_url, body: json_payload).response
    end
end
