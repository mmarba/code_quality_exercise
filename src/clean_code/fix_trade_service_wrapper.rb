#
# This class is a wrapper that contains encapsulates the implementation
# of the access to a REST trade service
#

require 'redis'

class FIXTradeServiceWrapper
    
    def initialize(redis_host_url)
        @connection = Redis.new(url: redis_host_url)
    end

    def send_to_redis(queue, command, payload = nil)
        redis_msg = payload == nil ? command : "#{command}::#{JSON.dump(payload)}" 
        @connection.rpush queue, redis_msg
    end

end

class MockedFIXTradeServiceWrapper < FIXTradeServiceWrapper
    def send_to_redis(queue, command, payload = nil)
        # stub that will be called when this object is provided 
        # as a mock fix trade service for testing purposes
        if queue == :lp_acme_provider_queue
            888
        elsif queue == :lp_wall_street_provider_queue
            999
        else
            000
        end
    end
end