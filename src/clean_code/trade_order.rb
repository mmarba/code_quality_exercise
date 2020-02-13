#
# This class contains the definition of the trade orders
#

class TradeOrder

    def initialize(side, size, currency, counter_currency, date, price, order_id)
        @side = side
        @size = size
        @currency = currency
        @counter_currency = counter_currency
        @date = date
        @price = price
        @order_id = order_id
    end

    # getter methods (no setters are needed)
    def side
        @side
    end
    
    def size
        @size
    end

    def currency
        @currency
    end

    def counter_currency
        @counter_currency
    end

    def date
        @date
    end

    def price
        @price
    end

    def order_id
        @order_id
    end

end
