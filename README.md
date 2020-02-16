# Code quality exercise for the trade execution service

## List of code smells and bad practices detected

- The Single Responsibility principle is not enforced, since there is one single class (TradeExecutionService) that does everything: the routing of the order to one provider or another depending on the amount, the execution of the order by sending it to the different providers, and the details of accessing a REST or a FIX service.

- There is a lot of conditional branching in the code. For instance, in the execute_order method depending on the selected provider a rest of fix trade request is done. 
This does not help readability. Also, it does not provide good maintainability: if a new type of provider was added, this code should be changed, resulting maybe in additional branching. In the case of the FIX-based providers, depending on whether it is A or B, the format of the request is different, which suggests that there should be two FIX provider classes, one for each behavior.

- Most methods have a very long list of parameters. This, with the points mentioned above, suggest that the part of the code should be moved to different classes where all the current parameters would be passed to the constructor at initialization.

- The error logging is implemented in the same TradeExecutionService class. There should be an external logging service to which the messages are sent so we do not depend on a specific implementation (writing in  a file in this case).
Also, details of the specific exception are not logged.

- Other smells:

  Hard-coded URLS in the code (such as in @connection = Redis.new(url: 'my_redis_host_url')).
  
  Constant USD not defined.


## Effects on testability of detected code smells/bad practices

- The fact that the REST and FIX calls is done inside the same class does not allow to mock it (in case we want to write unit tests or even integration tests that do not test the full workflow, where we might want to mock the dependencies to the REST and FIX services)

- All code in a single class makes it more difficult to track the root cause of failing tests. 


## Refactor

The code in TradeExecutionService has been decomposed in several specialized classes:

  - TradeOrder class to hold the details of the order.
  
  - LiquidityProvider class defining an interface that all LP's need to implement, plus specific implementations of LP's A, B, and C. This classes can be extended with new LP's as required.

  - Liquidity provider generation moved to new class LiquidityProviderRoutingService that encapsulates the business rules to determine the required LP.
  
  - TradeExecutionService contains the most basic workflow of obtaining the proper liquidity provider from the new LiquidityProviderService, and then sending the order to the obtained provider.
  
  - New classes to encapsulate the specific implementation of the access to the REST and FIX trading services.
  
  - New helper classes for the logger and the money manipulation operations.

## Rspec tests

The required tests have been written at two levels:

- File liquidity_provider_routing_service_spec.rb specified the tests of the class LiquidityProviderRoutingService, that verify that this provider returns the expected liquidity provider given an order. These tests are strictly speaking not unit tests (external dependencies are not replaced) but do not test the whole workflow of trading an order.

- Higher level, wider scope tests are specified in file trade_execution_service_spec.rb. The whole workflow of executing an order is performed for the different test scenarios.  The call to the REST or FIX external services is mocked using Rspec instance_doubles, that allow checking that for each order the correct REST (liquidity provider C) or FIX services are called. For the providers based in FIX (LP A or B), we can check that the correct provider is used by verifying that the FIX service is called with the parameters corresponding to one or the other.

Note: the routing rules specified in the document exercise do not include the expected behavior when the amount is exactly 100K USD (it says "equal or bigger than 10K but LESS than 100K" --> LP B, "BIGGER than 100K..." --> LP A). I have assumed, given the provided initial implementation of the rules in the code, that 100K --> LP A).

The code compiles and the tests pass. A gem file is provided in the code with the required dependencies.
