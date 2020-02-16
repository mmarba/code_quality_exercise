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

class MockResponse
    def initialize(code_value)
        @code_value = code_value
    end

    def code
        @code_value
    end
end

class MockedRESTTradeServiceWrapper < RESTTradeServiceWrapper
    def post_trade_request(json_payload)
        # stub that will be called when this object is provided 
        # as a mock rest trade service for testing purposes
        response = MockResponse.new(200)
    end
end
