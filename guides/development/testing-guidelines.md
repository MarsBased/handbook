# Testing guidelines

## Philosophy

Tests are documentation. They should clearly communicate what the code does and serve as living documentation for future developers. Prioritize readability and maintainability over cleverness.

## Test structure

Write tests as 3 separate blocks: **Arrange, Act, Assert** (also known as Given-When-Then).

```ruby
# Ruby (RSpec)
it "returns the user full name" do
  # Arrange
  user = create(:user, first_name: "John", last_name: "Doe")

  # Act
  result = user.full_name

  # Assert
  expect(result).to eq("John Doe")
end
```

```python
# Python (pytest)
def test_returns_user_full_name():
    # Arrange
    user = User(first_name="John", last_name="Doe")

    # Act
    result = user.full_name()

    # Assert
    assert result == "John Doe"
```

```typescript
// TypeScript (Jest/Vitest)
it("returns the user full name", () => {
  // Arrange
  const user = new User({ firstName: "John", lastName: "Doe" });

  // Act
  const result = user.fullName();

  // Assert
  expect(result).toBe("John Doe");
});
```

## Do's

- **Write boring tests.** The more boring a test is, the better.

  - Avoid abstractions unless there is a very good reason.
  - Repetition is acceptable. Copy & paste is allowed in tests.
  - Only extract to helper methods when it genuinely improves clarity.
  - Extracting large payloads or complex setup is fine.

- **Use human names** like "John" instead of "Candidate 1" or "User A". It makes tests more readable and creates a narrative.

- **Test against hardcoded values**, not dynamic references:

  ```ruby
  # Ruby - Good
  expect(json["name"]).to eq("John")

  # Ruby - Bad
  expect(json["name"]).to eq(user.name)
  ```

  ```python
  # Python - Good
  assert response["name"] == "John"

  # Python - Bad
  assert response["name"] == user.name
  ```

  ```typescript
  // TypeScript - Good
  expect(json.name).toBe("John");

  // TypeScript - Bad
  expect(json.name).toBe(user.name);
  ```

- **Mock every external call** to the internet (HTTP, gRPC, external APIs). Use libraries like:

  - Ruby: `webmock`, `vcr`
  - Python: `responses`, `httpretty`, `pytest-httpserver`
  - TypeScript: `msw`, `nock`

- **Test behavior, not implementation.** Focus on what the code does, not how it does it internally.

- **Keep tests fast.** Slow tests discourage running them frequently. Use unit tests for most coverage and reserve integration tests for critical paths.

- **One assertion per concept.** It's fine to have multiple `expect`/`assert` statements if they verify the same logical concept.

## Don'ts

- **Don't write "should" in test descriptions:**

  ```ruby
  # Ruby - Wrong
  it "should return the calculation result"

  # Ruby - Right
  it "returns the calculation result"
  ```

  ```python
  # Python - Wrong
  def test_should_return_calculation_result():

  # Python - Right
  def test_returns_calculation_result():
  ```

  ```typescript
  // TypeScript - Wrong
  it("should return the calculation result", ...)

  // TypeScript - Right
  it("returns the calculation result", ...)
  ```

- **Don't use faker/random value generators** (Faker, Chance, etc.) for most tests.

  - They can introduce flaky tests.
  - Hardcoded values help create a consistent story in the test suite.
  - **Exception:** Property-based testing / fuzz testing, where you intentionally run tests with random values to discover edge cases. Libraries: `hypothesis` (Python), `fast-check` (TypeScript), `rantly` (Ruby).

- **Don't test more than one thing per unit test.** Integration tests may verify multiple things since they are expensive to run.

- **Don't test private methods directly.** Test them through the public interface.

- **Don't share state between tests.** Each test should be independent and able to run in isolation.

- **Don't ignore flaky tests.** Fix them immediately or delete them. A flaky test is worse than no test.

## Test naming conventions

Use descriptive names that explain the scenario and expected outcome:

```ruby
# Ruby (RSpec)
describe User do
  describe "#full_name" do
    context "when user has both names" do
      it "returns first and last name concatenated" do
      end
    end

    context "when last name is missing" do
      it "returns only the first name" do
      end
    end
  end
end
```

```python
# Python (pytest)
class TestUser:
    class TestFullName:
        def test_returns_concatenated_names_when_both_present(self):
            pass

        def test_returns_first_name_when_last_name_missing(self):
            pass
```

```typescript
// TypeScript (Jest/Vitest)
describe("User", () => {
  describe("fullName", () => {
    it("returns first and last name concatenated when both present", () => {});

    it("returns only the first name when last name is missing", () => {});
  });
});
```

## Test organization

- **Unit tests:** Test individual functions/methods in isolation. Should be the majority of your tests.
- **Integration tests:** Test how components work together (e.g., API endpoints, database interactions).
- **End-to-end tests:** Test complete user flows. Use sparingly as they are slow and brittle.

Follow the testing pyramid: many unit tests, fewer integration tests, minimal E2E tests.

**When testing capacity is limited:** If a project's constraints (time, budget, team size) don't allow for comprehensive test coverage, prioritize E2E tests over unit tests. While slower and more brittle, E2E tests cover the most critical user paths with the fewest tests, providing maximum value per test written.

## What to test

- **Do test:** Business logic, edge cases, error handling, public APIs.
- **Don't test:** Framework code, simple getters/setters, third-party libraries.

## Database in tests

- Use transactions to rollback after each test when possible.
- Create only the data you need for each test.
- Use factories/fixtures to simplify data creation:
  - Ruby: `factory_bot`
  - Python: `factory_boy`, `pytest-factoryboy`
  - TypeScript: `fishery`, custom factories

## Continuous Integration

- All tests must pass before merging.
- Run the full test suite on every pull request.
- Keep the CI pipeline fast (< 10 minutes ideally but it depends on the project size).
