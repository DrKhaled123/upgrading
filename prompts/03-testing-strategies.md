# Testing & Validation Strategies (2025 Enhanced)
> **Purpose:** Comprehensive testing methodology from unit to E2E  
> **Approach:** Adversarial testing - tests designed to break code  
> **Goal:** False confidence elimination  

---

## 🎯 TESTING PHILOSOPHY

```
❌ OLD THINKING: "Tests prove code works"
✅ NEW THINKING: "Tests try to break code"

Adversarial Testing = QA mindset
- Assume bugs exist
- Aggressively hunt for them
- Test what shouldn't happen
- Verify negative cases
```

---

## TEST PYRAMID (Rebalanced)

```
        /\
       /  \      E2E Tests (10%)
      /----\     Critical user journeys
     /      \    
    /--------\   Integration Tests (30%)
   /          \  Module interactions
  /------------\ 
 /              \Unit Tests (60%)
/________________\Business logic
```

**Why This Distribution:**
- **Unit (60%):** Fast, isolated, comprehensive coverage
- **Integration (30%):** Module contracts, data flow
- **E2E (10%):** Critical paths only (slow, fragile)

---

## 5-TIER TEST SUITE DESIGN

### Tier 1: Happy Path (20% of tests)
**Purpose:** Verify baseline functionality

```javascript
describe('User Registration - Happy Path', () => {
  test('should create user with valid data', async () => {
    const user = await createUser({
      email: 'valid@example.com',
      password: 'SecurePass123!',
      name: 'John Doe'
    });
    
    expect(user.id).toBeDefined();
    expect(user.email).toBe('valid@example.com');
    expect(user.password).toBeUndefined(); // Never return password
  });
});
```

**Characteristics:**
- Standard valid inputs
- Expected workflows
- Baseline behavior

---

### Tier 2: Boundaries (40% of tests)
**Purpose:** Find off-by-one errors, edge cases

```javascript
describe('Input Validation - Boundaries', () => {
  test('should handle minimum length password', () => {
    // Boundary: exactly 8 characters
    const result = validatePassword('Abc1!'); // 5 chars - should fail
    expect(result.isValid).toBe(false);
  });

  test('should handle maximum string length', () => {
    // Boundary: 10,000 character limit
    const longName = 'a'.repeat(10000);
    const result = validateName(longName);
    expect(result.isValid).toBe(false);
  });

  test('should handle empty input', () => {
    const result = validateEmail('');
    expect(result.isValid).toBe(false);
  });

  test('should handle null/undefined', () => {
    expect(() => validateEmail(null)).toThrow();
    expect(() => validateEmail(undefined)).toThrow();
  });

  test('should handle special characters', () => {
    const result = validateUsername('user<script>');
    expect(result.isValid).toBe(false); // XSS prevention
  });

  test('should handle Unicode edge cases', () => {
    // Zero-width spaces, RTL characters
    const result = validateName('John\u200BDoe');
    expect(result.isValid).toBe(false);
  });
});
```

**Boundary Categories:**
- Min/max values
- Empty/null/undefined
- Special characters (XSS attempts)
- Unicode edge cases
- Large inputs
- Whitespace variations

---

### Tier 3: Error Cases (25% of tests)
**Purpose:** Verify graceful failure handling

```javascript
describe('Error Handling', () => {
  test('should handle database connection failure', async () => {
    // Mock DB failure
    jest.spyOn(db, 'query').mockRejectedValue(new Error('Connection refused'));
    
    await expect(createUser(validData))
      .rejects
      .toThrow('Database unavailable');
    
    // Verify no partial state
    expect(await db.query('SELECT * FROM users WHERE email = ?', [validData.email]))
      .toHaveLength(0);
  });

  test('should handle network timeout', async () => {
    jest.spyOn(api, 'fetch').mockRejectedValue(new Error('Timeout'));
    
    const result = await fetchUserData(123);
    
    // Should return cached data or graceful fallback
    expect(result).toBeDefined();
    expect(result.fromCache).toBe(true);
  });

  test('should handle malformed JSON', async () => {
    const response = await request(app)
      .post('/api/users')
      .set('Content-Type', 'application/json')
      .send('{"invalid json');
    
    expect(response.status).toBe(400);
    expect(response.body.error).toContain('Invalid JSON');
  });

  test('should handle SQL injection attempts', async () => {
    const maliciousInput = "'; DROP TABLE users; --";
    
    const result = await searchUsers(maliciousInput);
    
    // Should not crash, should not execute DROP
    expect(result).toBeInstanceOf(Array);
    expect(await db.query('SELECT * FROM users')).toBeDefined(); // Table exists
  });

  test('should handle concurrent modifications', async () => {
    // Two simultaneous updates to same record
    const promise1 = updateUser(1, { name: 'Alice' });
    const promise2 = updateUser(1, { name: 'Bob' });
    
    const [result1, result2] = await Promise.all([promise1, promise2]);
    
    // One should succeed, one should fail with conflict
    const successCount = [result1, result2].filter(r => r.success).length;
    expect(successCount).toBe(1);
  });
});
```

**Error Categories:**
- Network failures
- Database errors
- Timeout scenarios
- Malformed input
- Concurrent access
- Resource exhaustion
- Permission denied

---

### Tier 4: Contract Tests (15% of tests)
**Purpose:** Verify module interfaces and side effects

```javascript
describe('Module Contracts', () => {
  test('should return consistent types', async () => {
    const user = await getUser(1);
    
    // Type contract
    expect(typeof user.id).toBe('number');
    expect(typeof user.email).toBe('string');
    expect(user.createdAt).toBeInstanceOf(Date);
  });

  test('should be idempotent', async () => {
    // Calling twice should have same result as once
    await updateSettings(1, { theme: 'dark' });
    const first = await getSettings(1);
    
    await updateSettings(1, { theme: 'dark' });
    const second = await getSettings(1);
    
    expect(first).toEqual(second);
  });

  test('should handle side effects', async () => {
    const emailSpy = jest.spyOn(emailService, 'send');
    
    await createUser({ email: 'test@example.com' });
    
    // Verify side effect occurred
    expect(emailSpy).toHaveBeenCalledWith({
      to: 'test@example.com',
      template: 'welcome'
    });
  });

  test('should clean up resources', async () => {
    const initialConnections = db.getConnectionCount();
    
    await processLargeFile('data.csv');
    
    // Connections should be released
    expect(db.getConnectionCount()).toBe(initialConnections);
  });

  test('should maintain invariants', async () => {
    // Account balance should never be negative
    await expect(withdraw(1, 999999))
      .rejects
      .toThrow('Insufficient funds');
    
    const account = await getAccount(1);
    expect(account.balance).toBeGreaterThanOrEqual(0);
  });
});
```

**Contract Verifications:**
- Return type consistency
- Idempotency
- Side effects
- Resource cleanup
- Invariants maintained

---

### Tier 5: Mutation Testing
**Purpose:** Verify test suite quality

```bash
# Run mutation testing
npx stryker run

# Review survived mutations
npx stryker dashboard
```

**Interpretation:**
```
KILLED: Test caught the mutation (good)
SURVIVED: Test didn't catch the mutation (bad - weak test)
TIMEOUT: Mutation caused infinite loop
ERROR: Mutation caused compilation/runtime error

TARGET: >80% kill rate
```

---

## TEST ANTI-PATTERNS (To Avoid)

### 1. Tautological Tests
```javascript
// ❌ BAD - Tests implementation, not behavior
const result = calculateSum(2, 3);
expect(calculateSum).toHaveBeenCalled(); // Useless assertion
expect(result).toBeDefined(); // Too vague

// ✅ GOOD
expect(result).toBe(5);
```

### 2. Over-Mocking
```javascript
// ❌ BAD - Everything mocked, testing nothing real
jest.mock('./database');
jest.mock('./api');
jest.mock('./cache');
// Test passes but doesn't verify real integration

// ✅ GOOD - Mock only external dependencies
db.query = jest.fn().mockResolvedValue([mockUser]);
// Use real implementation for internal modules
```

### 3. Missing Negative Tests
```javascript
// ❌ BAD - Only tests success
await createUser(validData);
expect(user).toBeDefined();

// ✅ GOOD - Tests failures too
await expect(createUser(invalidEmail)).rejects.toThrow();
await expect(createUser(duplicateEmail)).rejects.toThrow();
```

### 4. Flaky Tests
```javascript
// ❌ BAD - Timing dependent
test('async operation', async () => {
  await operation();
  await new Promise(r => setTimeout(r, 100)); // Arbitrary delay
  expect(result).toBe(true); // May fail on slow CI
});

// ✅ GOOD - Explicit synchronization
test('async operation', async () => {
  const result = await operation();
  expect(result).toBe(true);
});
```

### 5. Coverage Theater
```javascript
// ❌ BAD - Line executed but not verified
function processData(data) {
  const result = transform(data); // Line "covered" but not asserted
  return result;
}

test('processData', () => {
  processData({}); // Calls function but doesn't check output
});

// ✅ GOOD - Assert outcomes
test('processData transforms correctly', () => {
  const result = processData({ value: 5 });
  expect(result).toEqual({ value: 10 }); // Specific assertion
});
```

---

## INTEGRATION TESTING STRATEGIES

### Contract Testing Between Services

```javascript
// Consumer tests (API client)
describe('UserService API Contract', () => {
  test('should deserialize user response correctly', async () => {
    const user = await userService.getUser(1);
    
    // Contract: Response structure
    expect(user).toMatchObject({
      id: expect.any(Number),
      email: expect.any(String),
      createdAt: expect.any(Date)
    });
  });
});

// Provider tests (API server)
describe('User API Provider Contract', () => {
  test('should return valid user structure', async () => {
    const response = await request(app).get('/api/users/1');
    
    expect(response.body).toMatchSchema({
      type: 'object',
      required: ['id', 'email', 'createdAt'],
      properties: {
        id: { type: 'number' },
        email: { type: 'string', format: 'email' }
      }
    });
  });
});
```

### Database Integration

```javascript
describe('Database Integration', () => {
  beforeEach(async () => {
    // Clean slate for each test
    await db.query('TRUNCATE users CASCADE');
  });

  test('should persist and retrieve user', async () => {
    const created = await User.create({ email: 'test@example.com' });
    
    const retrieved = await User.findById(created.id);
    
    expect(retrieved.email).toBe('test@example.com');
  });

  test('should enforce unique constraints', async () => {
    await User.create({ email: 'unique@example.com' });
    
    await expect(User.create({ email: 'unique@example.com' }))
      .rejects
      .toThrow('duplicate key');
  });
});
```

---

## E2E TESTING BEST PRACTICES

### Critical Path Only

```javascript
// Test ONLY critical user journeys
describe('Critical User Journeys', () => {
  test('user can complete purchase', async () => {
    // Full flow: browse → cart → checkout → confirmation
    await page.goto('/products');
    await page.click('[data-testid="add-to-cart"]');
    await page.click('[data-testid="checkout"]');
    await page.fill('[name="email"]', 'user@example.com');
    // ... complete checkout
    
    await expect(page.locator('[data-testid="confirmation"]'))
      .toBeVisible();
  });
});
```

### Page Object Pattern

```javascript
// Page object for maintainability
class LoginPage {
  constructor(page) {
    this.page = page;
    this.emailInput = page.locator('[name="email"]');
    this.passwordInput = page.locator('[name="password"]');
    this.submitButton = page.locator('[type="submit"]');
  }

  async login(email, password) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}

// Usage
test('login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.login('user@example.com', 'password');
});
```

---

## TEST DATA MANAGEMENT

### Factory Pattern

```javascript
// factories/user.js
const { faker } = require('@faker-js/faker');

module.exports = {
  build: (overrides = {}) => ({
    email: faker.internet.email(),
    name: faker.person.fullName(),
    password: faker.internet.password(),
    ...overrides
  }),
  
  create: async (overrides = {}) => {
    return await User.create(module.exports.build(overrides));
  }
};

// Usage
const user = await userFactory.create({ email: 'specific@example.com' });
```

---

## METRICS & GOALS

| Metric | Target | Tools |
|--------|--------|-------|
| Line Coverage | 80%+ | Jest, coverage.py |
| Branch Coverage | 75%+ | Built-in reporters |
| Function Coverage | 90%+ | Istanbul/nyc |
| Mutation Score | 80%+ | Stryker, Mutmut |
| Test Execution Time | <5 min | Parallelization |
| Flaky Test Rate | <1% | Test retries analysis |

---

## UPGRADES FROM ORIGINAL

### Key Improvements:

1. **Tier 5 Added: Mutation Testing**
   - Verifies test suite quality
   - Identifies weak tests
   - Targets 80% kill rate

2. **Anti-Patterns Catalog**
   - 5 common mistakes
   - Before/after examples
   - Detection guidelines

3. **Real Code Examples**
   - Copy-paste ready
   - Multiple languages
   - Production patterns

4. **Test Data Management**
   - Factory pattern
   - Faker integration
   - Maintainable fixtures

5. **Integration Strategies**
   - Contract testing
   - Database integration
   - E2E best practices

6. **Measurable Targets**
   - Coverage goals
   - Execution time limits
   - Flaky test monitoring

---

> **Version:** 2.0 (2025)  
> **Status:** Production-Ready  
> **Use:** Test strategy, coverage improvement, quality gates
