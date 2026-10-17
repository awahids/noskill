<!-- Part of the coding-standards skill: function code examples, TDD, test anti-patterns, and simplify pass. -->
# Coding Standards — Function Examples, TDD, and Simplify Pass

## 5. Function & Method — examples

Example:
```typescript
// ❌ Worse
async function getUser(id) {
  const user = await this.repo.find(id);
  return user;
}

// ✅ Better
async function getUserById(id: string): Promise<UserResponseDto> {
  const user = await this.userRepository.findById(id);
  if (!user) {
    throw new NotFoundException(`User with id ${id} not found`);
  }
  return UserMapper.toDto(user);
}
```

**Golang — idiomatic error handling (return errors, don't panic for expected errors):**
```go
// ❌ Worse — error silently swallowed
func GetOrderByID(id string) *Order {
    order, _ := repo.FindByID(id)
    return order
}

// ✅ Better — error wrapped with context, sentinel error for specific cases
var ErrOrderNotFound = errors.New("order not found")

func (s *OrderService) GetOrderByID(ctx context.Context, id string) (*Order, error) {
    order, err := s.repo.FindByID(ctx, id)
    if errors.Is(err, sql.ErrNoRows) {
        return nil, ErrOrderNotFound
    }
    if err != nil {
        return nil, fmt.Errorf("failed to get order %s: %w", id, err)
    }
    return order, nil
}
```
- `panic` only for errors that truly must never happen (programmer error), not for expected errors such as "data not found"
- A handler receiving an error from the service maps it to the appropriate HTTP status code (`errors.Is(err, ErrOrderNotFound)` → 404), not a generic 500 for every error

## 5.1 TDD — RED → GREEN → REFACTOR cycle example

```typescript
// 1. RED — test first, calculateExcessAmount not implemented yet
it('should return 0 excess when subsidy covers full meal price', () => {
  expect(calculateExcessAmount({ mealPrice: 15000, subsidyAmount: 15000 })).toBe(0);
});
it('should return the gap when subsidy is less than meal price', () => {
  expect(calculateExcessAmount({ mealPrice: 15000, subsidyAmount: 10000 })).toBe(5000);
});

// 2. GREEN — minimal implementation
function calculateExcessAmount({ mealPrice, subsidyAmount }: { mealPrice: number; subsidyAmount: number }): number {
  return Math.max(0, mealPrice - subsidyAmount);
}

// 3. REFACTOR — tidy further if needed; the tests above are the safety net
```

## 5.2 Quality Gates — anti-pattern

Anti-pattern example to avoid:
```typescript
// ❌ The test originally expected expect(result).toBe(150000) and failed due to a calculation bug
// Then it was "fixed" by changing the expected value to match the wrong output:
expect(result).toBe(145000);  // <- this hides the bug instead of finding it
```
If the expected value changes because the requirement really changed, that is legitimate — the difference lies in the reason for the change, not just "to make it pass".

## 5.3 Simplify Pass — After the Feature Works

After the implementation passes tests and quality gates, there is a separate stage to tidy the code **without changing its behavior**:
- Targets: confusing nested ternaries, functions doing more than one thing, logic too dense/hard to read at a glance, abstractions that made sense when written but are now confusing
- **Strict rule: you may only change *how* the behavior is expressed, never the behavior itself.** If the simplify pass needs to change logic/results, it is no longer a simplify — it is a functional change needing new/updated tests
- Rerun the tests after the simplify pass to make sure they are still green — if a test fails after "just tidying", the behavior changed along with it; that is a new bug to fix, not a sign the test needs adjusting
- Not needed for trivial code; most useful for logic written quickly early in implementation and not yet tidied
