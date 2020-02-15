#
# Helper for money operations.
#

require 'money'
USD = "USD"

class MoneyHelper

    def self.amount_in_usd(size, currency)
        if currency == USD
            amount = Money.from_amount(size, USD)
        else     
            # this is just to cover the case where the currency is not USD
            # for testing purposes we assume any other currency value is half the USD value
            amount = Money.from_amount(size*2, USD)
        end
    end
    
end

class Integer
    def to_money(currency)
      MoneyHelper.amount_in_usd(self, currency)
    end
end