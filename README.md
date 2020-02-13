# Code quality exercise for the trade execution service

## List of code smells and bad practices detected

- The Single responsibility principle is not enforced, since there is one single class (TradeExecutionService) that does everything: the routing of the order to one provider or another depending on the amount, the execution of the order by sending it to the different providers, and the details of accessing a REST or a FIX service.

- There is a lot of conditional branching in the code. For instance, in the execute_order method depending on the selected provider a rest of fix trade request is done. This does not provide good maintainability: if a new type of provider was added, this code should be changed, resulting maybe in additional branching. In the case of the FIX-based providers, depending on whether it is A or B, the format of the request is different, which suggests that there should be two FIX provider classes, one for each behavior.

- Most methods have a very long list of parameters. This, with the points mentioned above, suggest that the part of the code should be moved to different classes where all the current parameters would be passed to the constructor at initialization.

- Hard-coded log file path in File.open('path_to_log_file/errors.log', 'a') do |f|

- The error logging is implemented in the same class. There should be an external logging service to which the messages are sent so we do not depend on a specific implementation (writing in  a file in this case)

- Other smells:

  Hard-coded URLS in the code (such as in @connection = Redis.new(url: 'my_redis_host_url')).
  Constant USD not defined.


## Refactor

The TradeExecutionService will be "cleaned" so that it contains the most basic workflow of obtaining the proper liquidity provider from a new LiquidityProviderService, and then sending the order to the obtained provider (which will be an external object).

