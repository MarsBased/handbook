# Testing guidelines

**NOTE: This guide is work in progress. This is just the layout to be properly written.**

Do's
* Write tests as 3 separate blocks (data preparation, execution and expectation)
* Write boring tests. The most boring a test is the better.
  * You should only use abstractions if there is a very good reason.
  * It's ok to have repetition. Copy & paste is allowed in tests.
    * Only extract to helper methods when it makes sense.
    * Of course some repetition is helpful to extract large payloads for example.
* Use human names "John" instead of "Candidate 1".
* Test against hardcoded values: expect(json['name']).to eq 'John' instead of expect(json['name']).to eq candiate.name.
  * Write code example.
* Mock every external call to the internet (HTTP, gPRPC)

Don'ts
* Don’t write “should” in spec messages:
  * Wrong: it “should return the calculation result”
  * Right: it “returns the calculation result”
* In general, Don't use faker (fake values generating library), use hardcoded values.
  * They could introduce flaky tests.
  * Having hardcoded values helps create a story in the test suite.
  * Exception: Running tests with a series of random values to find bugs (we don't remember the name of this testing technique, if someones remembers put it here please).
* Don't test more than one thing per test in unit tests. Integration tests are allowed to test more than one thing because they are expensive to run.
