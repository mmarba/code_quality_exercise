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