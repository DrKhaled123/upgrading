code best skills.md

# The Complete Developer's Guide: Code Excellence & Mastery
## Part 1: Characteristics of Best Code

The finest code reads like well-written prose. When another developer opens your file six months from now, they should understand its purpose within seconds. This is the foundation upon which all other qualities rest.

### 1. Readability: The Non-Negotiable Foundation

**The single most important quality—code is read 10x more than it's written.**

Core characteristics:
- **Self-documenting names**: `userAccountBalance` tells a story while `x` tells nothing
- **Consistent formatting**: Use linters (ESLint, Prettier) to enforce uniformity
- **Comments that explain why**: Obvious code shows what; comments reveal intent
- **Meaningful structure**: Maximum function length of 20-30 lines; related code grouped logically

**Before & After Examples:**

```javascript
// ❌ Poor readability
function p(d) {
  let t = 0;
  for(let i=0;i<d.length;i++){t+=d[i].a*d[i].q;}
  return t*1.08;
}

// ✅ Excellent readability
function calculateOrderTotal(orderItems) {
  const subtotal = orderItems.reduce((sum, item) => {
    return sum + item.price * item.quantity;
  }, 0);
  
  const TAX_RATE = 0.08;
  return subtotal * (1 + TAX_RATE);
}
```

```javascript
// ❌ Bad: Obvious comment
// Increment counter by 1
counter++;

// ✅ Good: Explains reasoning
// Skip cache for admin users to prevent stale permission data
if (user.isAdmin) {
  bypassCache = true;
}
```

### 2. Simplicity: Resist Complexity

> *"Any fool can write code that a computer can understand. Good programmers write code that humans can understand." — Martin Fowler*

**The KISS Principle (Keep It Simple, Stupid) & YAGNI (You Aren't Gonna Need It)**

Core characteristics:
- Solves the **actual** problem, not imagined future problems
- Uses standard library features before adding dependencies
- Avoids clever tricks that sacrifice clarity

**Examples:**

```python
# ❌ Over-engineered
class AbstractSingletonProxyFactoryBean:
    def get_instance(self):
        if not hasattr(self, '_instance'):
            self._instance = self._create_instance()
        return self._instance

# ✅ Simple and direct
def get_user(user_id):
    return database.query("SELECT * FROM users WHERE id = ?", user_id)
```

```javascript
// ❌ "Clever" but confusing
const isEven = n => !(n & 1);

// ✅ Clear and obvious
const isEven = n => n % 2 === 0;
```

### 3. Maintainability: Code That Welcomes Change

Code is written once but read and modified hundreds of times. Maintainable code anticipates change and enables future developers to work confidently.

Core characteristics:
- **Modular design** (Single Responsibility Principle)
- **Low coupling, high cohesion**
- **Testable architecture** through dependency injection
- **Clear error handling** (never silent failures)

**Examples:**

```python
# ❌ God class doing everything
class UserManager:
    def create_user(self, data): ...
    def send_email(self, user): ...
    def charge_credit_card(self, user, amount): ...
    def generate_pdf_report(self, user): ...

# ✅ Separated concerns
class UserRepository:
    def create(self, data): ...

class EmailService:
    def send_welcome_email(self, user): ...

class PaymentService:
    def charge(self, user, amount): ...
```

```javascript
// ❌ Hard to test (tight coupling)
function processOrder() {
  const db = new Database('prod-connection');
  const payment = new StripeAPI('live-key');
  // ... complex logic
}

// ✅ Easy to test (dependency injection)
function processOrder(database, paymentService) {
  // ... same logic, mockable dependencies
}
```

```javascript
// ❌ Silent failure
try {
  await api.call();
} catch (e) {}

// ✅ Explicit handling
try {
  await api.call();
} catch (error) {
  logger.error('API call failed', { error, context });
  throw new APIError('Unable to process request', { cause: error });
}
```

### 4. Efficiency: Fast Enough, Not Prematurely Optimized

> *"Premature optimization is the root of all evil" — Donald Knuth*

**Performance-conscious but not obsessed.**

Core characteristics:
- **Appropriate algorithmic complexity** (Big O awareness)
- **Memory-conscious design** (streaming over loading)
- **Proper caching strategies**
- **Optimize only after profiling**

**Examples:**

```python
# ❌ O(n²) - inefficient for large lists
def find_duplicates(items):
    duplicates = []
    for i, item in enumerate(items):
        for j, other in enumerate(items):
            if i != j and item == other:
                duplicates.append(item)
    return duplicates

# ✅ O(n) - efficient
def find_duplicates(items):
    seen = set()
    duplicates = set()
    for item in items:
        if item in seen:
            duplicates.add(item)
        seen.add(item)
    return list(duplicates)
```

```javascript
// ❌ Loads entire file into memory
const data = fs.readFileSync('huge-file.txt', 'utf8');

// ✅ Streams large data
const stream = fs.createReadStream('huge-file.txt');
stream.on('data', chunk => process(chunk));
```

```python
from functools import lru_cache

@lru_cache(maxsize=128)
def expensive_calculation(n):
    # Computed once per unique input, then cached
    return sum(i ** 2 for i in range(n))
```

### 5. Robustness: Handles Reality, Not Just Happy Paths

Production code operates in an imperfect world where networks fail, users enter invalid data, and external services timeout. Robust code anticipates failure modes.

Core characteristics:
- **Defensive programming** (never trust input)
- **Input validation** (fail fast on bad data)
- **Graceful degradation** (partial functionality is better than none)

**Examples:**

```javascript
// ❌ Assumes perfect input
function getFirstName(user) {
  return user.name.split(' ')[0];
}

// ✅ Handles edge cases
function getFirstName(user) {
  if (!user || typeof user.name !== 'string') {
    return '';
  }
  const parts = user.name.trim().split(' ');
  return parts[0] || '';
}
```

```python
def withdraw(account, amount):
    if amount <= 0:
        raise ValueError("Amount must be positive")
    if amount > account.balance:
        raise InsufficientFundsError(f"Balance: {account.balance}")
    account.balance -= amount
```

```javascript
// ✅ Falls back if feature unavailable
function trackAnalytics(event) {
  if (typeof analytics !== 'undefined') {
    try {
      analytics.track(event);
    } catch (error) {
      console.warn('Analytics tracking failed', error);
    }
  }
}
```

### 6. Security: Treat All Input as Hostile

Secure code protects against vulnerabilities by design, not as an afterthought.

Core characteristics:
- **Input sanitization and validation**
- **Proper authentication/authorization**
- **Secrets management** (never hardcoded)
- **Protection against OWASP Top 10**

**Examples:**

```javascript
// ❌ SQL injection vulnerability
const query = `SELECT * FROM users WHERE id = ${userId}`;

// ✅ Parameterized query
const query = 'SELECT * FROM users WHERE id = ?';
db.execute(query, [userId]);
```

```python
def delete_post(post_id, current_user):
    post = Post.get(post_id)
    if post.author_id != current_user.id and not current_user.is_admin:
        raise PermissionError("Cannot delete another user's post")
    post.delete()
```

```javascript
// ❌ Hardcoded secrets
const apiKey = 'sk_live_abc123xyz';

// ✅ Environment variables
const apiKey = process.env.STRIPE_API_KEY;
```

### 7. Documentation: Strategic Explanation

Self-documenting code represents the ideal, but complex systems need external docs that explain architecture, decisions, and usage.

Core characteristics:
- **API documentation** (parameters, return values, examples)
- **README with setup instructions**
- **Architecture Decision Records (ADRs)**
- **Inline comments for complex algorithms**

**Example:**

```python
def calculate_compound_interest(principal, rate, years, compounds_per_year=12):
    """
    Calculate compound interest.
    
    Args:
        principal (float): Initial investment amount
        rate (float): Annual interest rate (e.g., 0.05 for 5%)
        years (int): Number of years
        compounds_per_year (int): Compounding frequency (default: 12 for monthly)
    
    Returns:
        float: Final amount after compound interest
    
    Example:
        >>> calculate_compound_interest(1000, 0.05, 10)
        1647.01
    """
    return principal * (1 + rate/compounds_per_year) ** (years * compounds_per_year)
```

---

## Part 2: Characteristics of Expert Coding Skills

### 1. Problem-Solving Ability

**Systematic debugging methodology:**
1. Reproduce the bug consistently
2. Isolate the problematic code section
3. Form hypothesis about the cause
4. Test hypothesis
5. Fix and verify

**Practical Example:** Building a recommendation system

1. **Break down**:
   - Data collection (user behavior tracking)
   - Feature extraction (user preferences)
   - Similarity calculation (collaborative filtering)
   - Ranking algorithm (sort by relevance score)
   - Caching layer (performance optimization)

2. **Start with simplest solution** (content-based filtering)
3. **Measure performance**
4. **Iterate** with improvements (add collaborative filtering)

### 2. Design Thinking & Architecture

**SOLID Principles:**
- Single Responsibility
- Open/Closed (open for extension, closed for modification)
- Liskov Substitution
- Interface Segregation
- Dependency Inversion

**Design Patterns Knowledge:**

```javascript
// Factory Pattern - creates objects without specifying exact class
class UserFactory {
  static create(type, data) {
    switch(type) {
      case 'admin': return new AdminUser(data);
      case 'guest': return new GuestUser(data);
      default: return new RegularUser(data);
    }
  }
}

// Observer Pattern - one-to-many dependency
class EventEmitter {
  constructor() {
    this.listeners = {};
  }
  
  on(event, callback) {
    if (!this.listeners[event]) {
      this.listeners[event] = [];
    }
    this.listeners[event].push(callback);
  }
  
  emit(event, data) {
    if (this.listeners[event]) {
      this.listeners[event].forEach(callback => callback(data));
    }
  }
}
```

**System Design Skills:**
- Load balancing strategies
- Database sharding and replication
- Caching layers (Redis, CDN)
- Microservices vs. monolith trade-offs
- API design (REST, GraphQL, gRPC)

### 3. Code Quality Awareness

**Refactoring Techniques:**

```javascript
// Before: Long method with multiple responsibilities
function processUserData(data) {
  // 50 lines of validation
  // 30 lines of transformation
  // 20 lines of database saving
  // 15 lines of email sending
}

// After: Refactored into focused functions
function processUserData(data) {
  const validatedData = validateUserData(data);
  const transformedData = transformUserData(validatedData);
  const savedUser = saveUser(transformedData);
  sendWelcomeEmail(savedUser);
  return savedUser;
}
```

**Code Smell Recognition:**
- Duplicated code
- Long methods/classes
- Too many parameters
- Feature envy (method uses another class's data more than its own)
- Inappropriate intimacy (classes too coupled)

**Technical Debt Management:**
```javascript
// Document shortcuts
// TODO: Temporary fix for edge case; refactor when adding multi-currency support
```

### 4. Testing Proficiency

**Test-Driven Development (TDD):**
```python
# 1. Write failing test first
def test_calculate_discount():
    assert calculate_discount(100, 0.2) == 80
    assert calculate_discount(50, 0.5) == 25

# 2. Write minimum code to pass
def calculate_discount(price, discount_rate):
    return price * (1 - discount_rate)

# 3. Refactor while keeping tests green
```

**Test Coverage Knowledge:**
- Unit tests (individual functions)
- Integration tests (component interactions)
- End-to-end tests (full user workflows)
- Knowing what NOT to test (implementation details)

**Mocking and Stubbing:**
```javascript
// Mock external API for testing
jest.mock('./apiClient');

test('fetches user data', async () => {
  apiClient.get.mockResolvedValue({ id: 1, name: 'John' });
  const user = await getUserById(1);
  expect(user.name).toBe('John');
});
```

**Edge Case Testing:**
```python
def test_division():
    # Happy path
    assert divide(10, 2) == 5
    
    # Edge cases
    assert divide(0, 5) == 0
    assert divide(10, 3) == 3.333...
    
    # Error cases
    with pytest.raises(ZeroDivisionError):
        divide(10, 0)
```

### 5. Version Control Mastery

**Meaningful Commit Messages:**
```bash
# ❌ Bad
git commit -m "fix"
git commit -m "update stuff"

# ✅ Good (conventional commits format)
git commit -m "fix(auth): resolve token expiration bug in session middleware"
git commit -m "feat(api): add pagination to user list endpoint"
```

**Branching Strategies:**
```bash
# Feature branch workflow
git checkout -b feature/user-authentication
# ... make changes
git commit -m "feat(auth): implement JWT authentication"
git push origin feature/user-authentication
# Create pull request for review
```

### 6. Continuous Learning

**Learning Strategies:**
1. Build projects (learning by doing)
2. Read others' code (GitHub, open source)
3. Pair programming (knowledge sharing)
4. Technical blogs and books
5. Conferences and meetups
6. Online courses (targeted skill gaps)

**Skill Evaluation:**
```bash
# Monthly self-assessment template
## What I Learned This Month
- New tool: Vitest for testing
- New pattern: Factory pattern implementation
- New skill: Database query optimization

## Gaps to Fill
- Need to learn container orchestration
- Need to practice system design interviews
```

### 7. Collaboration Skills

**Code Review Etiquette:**
```markdown
# ❌ Unhelpful review comment
"This is bad. Rewrite it."

# ✅ Constructive feedback
"This function has high cyclomatic complexity (8). Consider extracting
the validation logic into a separate helper function. Example:

function validateUserInput(data) {
  // validation logic here
}

This would improve testability and readability."
```

**Pair Programming:**
- Driver/Navigator roles
- Ping-pong TDD
- Knowledge transfer

**Mentoring:**
- Guide, don't give answers
- Provide context and reasoning
- Set up for success with documentation

### 8. Domain Knowledge & Business Context

**Asking "Why" Before "How":**
```python
# Business: "We need this feature by Friday"
# Poor response: "Okay" (then deliver buggy code)
# Good response: "I can deliver a basic version by Friday with X and Y
# features. For the full scope including Z, we'd need until Tuesday.
# Which is more important—speed or completeness?"
```

**Balancing Technical & Business Concerns:**
- Understand user needs
- Question unclear requirements
- Propose alternative solutions

### 9. Performance Optimization

**Profile First, Optimize Second:**
```javascript
// Measure before optimizing
console.time('operation');
processLargeDataset(data);
console.timeEnd('operation');
```

**Database Query Optimization:**
```sql
-- ❌ Slow: N+1 query problem
SELECT * FROM users;
-- Then for each user:
SELECT * FROM posts WHERE user_id = ?;

-- ✅ Fast: Single join query
SELECT users.*, posts.* 
FROM users 
LEFT JOIN posts ON users.id = posts.user_id;
```

**Lazy Loading & Code Splitting:**
```javascript
// Lazy load heavy components
const HeavyChart = React.lazy(() => import('./HeavyChart'));
```

### 10. Pragmatism & Trade-offs

**Understanding Trade-offs:**
- Startup MVP: **Fast > Scalable > Maintainable**
- Enterprise system: **Maintainable > Scalable > Fast**
- High-frequency trading: **Fast > Maintainable > Scalable**

**Avoiding Premature Abstraction:**
```javascript
// Duplicating code twice is okay; refactor on the third time
// Don't repeat yourself (DRY) is important, but premature DRY creates coupling
```

**Saying "No" to Unnecessary Complexity:**
```bash
# When asked to add a message queue for simple email sending:
"For our current volume (10 emails/day), a queue adds complexity without benefit.
If we exceed 100/day, let's revisit this decision."
```

---

## Practical Development of Coding Skills

### Daily Practices (30-60 min)
- Code every day (even small commits)
- Read excellent code on GitHub
- Be your own first reviewer
- Learn from every bug (post-mortem)

### Weekly Practices (2-3 hours)
| Activity | Time | Benefit |
|----------|------|---------|
| Deep dive into one concept | 1 hour | Mastery at depth |
| Contribute to open source | 1 hour | Real-world collaboration |
| Participate in code reviews | 30 min | Multi-perspective learning |
| Technical reading | 30 min | Stay current |

### Monthly Practices (Half-day)
- Refactor old code (measure your growth)
- Write a technical blog post (teaching solidifies learning)
- Complete a coding challenge (stretch your skills)
- Update skills inventory (track progress and gaps)
- Mentor someone (strengthen your own understanding)

---

## The Mindset of Great Developers

| Mindset | Manifestation | Counterexample |
|---------|---------------|----------------|
| **Humble** | "I don't know everything" | Defending bad code out of pride |
| **Curious** | "Why does it work this way?" | Copy-pasting without understanding |
| **Pragmatic** | "Simplest solution for the problem" | Over-engineering for imaginary needs |
| **Empathetic** | "Will future me understand this?" | Writing cryptic one-liners |
| **Quality-focused** | "I take pride in my craft" | "It works, ship it" mentality |
| **Growth-oriented** | "Every bug is a learning opportunity" | Blaming the compiler |
| **User-centric** | "Does this actually help users?" | Building features nobody asked for |

---

## Summary: The Complete Developer

The finest code emerges from developers who combine **technical excellence** with **professional maturity**. They write code that is readable, simple, maintainable, testable, efficient, robust, secure, and well-documented. They bring skills in problem decomposition, debugging, learning, communication, systems thinking, attention to detail, collaboration, time management, and ethics.

These characteristics reinforce each other. Code written for readability tends toward simplicity. Testable code tends toward maintainability. Developers who communicate well tend to collaborate effectively.

**The ultimate characteristic**: Code that works, is understandable, and can be changed easily by someone who didn't write it.

The journey toward excellence is lifelong—even the most experienced developers continue refining their craft, learning from mistakes, and adapting to new challenges. The goal is not perfection but continuous improvement. Every code review, every debugging session, every new project offers opportunities to sharpen skills and deepen understanding.

The best developers approach their craft with **humility, curiosity, and persistent dedication** to getting better.

//////////////////////////////////////////////////////////////////

Below is a language‑and‑framework‑specific cheat‑sheet that maps the universal qualities of “best code” (readability, simplicity, maintainability, …) to the concrete conventions, tools, and idioms you should follow for each stack.
For every entry you’ll see:

* What to look for – a short description of the quality in that ecosystem.
* Tooling / linting – the de‑facto linters, formatters, or static‑analysis helpers.
* Key conventions – naming, file layout, common patterns.
* Sample snippet – a tiny “good vs. bad” illustration written in the native language.


1. Python + Django / Flask
QualityWhat it means in PythonTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow PEP 8 and PEP 257 (docstrings). Use expressive variable names; avoid one‑letter locals except in short loops.flake8, black, isort, pylintsnake_case for functions/variables, PascalCase for classes, module‑level constants in ALL_CAPS.python\n# ❌ Bad – cryptic, no docstring\ndef f(a,b):\n    return a*b\n\n# ✅ Good – self‑documenting, typed, docstring\ndef calculate_total_price(unit_price: float, quantity: int) -> float:\n    \"\"\"Return the total price for *quantity* items at *unit_price* each.\n    Args:\n        unit_price: Price of a single item.\n        quantity: Number of items.\n    \"\"\"\n    return unit_price * quantity\nSimplicityPrefer the standard library; use list‑comprehensions or generator expressions instead of manual loops.bandit (security), mypy (type checking)Use dataclasses for simple structs, avoid over‑engineering with heavy OO when a function suffices.python\n# ❌ Over‑engineered\nclass Order:\n    def __init__(self, items):\n        self.items = items\n    def total(self):\n        total = 0\n        for i in self.items:\n            total += i.price * i.qty\n        return total\n\n# ✅ Simple\nfrom dataclasses import dataclass\n\n@dataclass\nclass Item:\n    price: float\n    qty: int\n\ndef order_total(items: list[Item]) -> float:\n    return sum(i.price * i.qty for i in items)\nMaintainabilityKeep views thin, push business logic to services or managers; use class‑based views (Django) or blueprints (Flask).django‑check, pytest‑djangoOne file per app, models.py, views.py, forms.py, urls.py.python\n# ❌ Fat view\ndef create_user(request):\n    if request.method == \"POST\":\n        data = json.loads(request.body)\n        if not validate(data):\n            return JsonResponse({\"error\": \"bad\"}, status=400)\n        user = User.objects.create(**data)\n        send_welcome_email(user)\n        return JsonResponse({\"id\": user.id})\n\n# ✅ Thin view + service\n# views.py\nfrom .services import create_user_service\n\ndef create_user(request):\n    if request.method != \"POST\":\n        return JsonResponse({\"error\": \"method\"}, status=405)\n    payload = json.loads(request.body)\n    try:\n        user = create_user_service(payload)\n    except ValidationError as e:\n        return JsonResponse({\"error\": str(e)}, status=400)\n    return JsonResponse({\"id\": user.id})\nPerformanceUse queryset lazy evaluation; select_related/prefetch_related to avoid N+1 queries.django‑debug‑toolbar, sql‑inspectCache heavy queries (django‑cacheops, Redis).python\n# ❌ N+1\norders = Order.objects.all()\nfor o in orders:\n    print(o.customer.email)   # extra query per order\n\n# ✅ Prefetch\norders = Order.objects.select_related('customer').all()\nfor o in orders:\n    print(o.customer.email)   # single join query\nSecurityEnable CSRF protection, use Django’s built‑in password hashing, validate inputs, avoid eval.bandit, safety (dependency checker)Use django‑environ for secrets, never hard‑code API keys.python\n# ❌ Hard‑coded secret\nAPI_KEY = \"sk_live_12345\"\n\n# ✅ Environment‑based\nimport environ\nenv = environ.Env()\nAPI_KEY = env.str(\"API_KEY\")\nTestingWrite unit tests for pure functions; use pytest + pytest‑django for integration.coverage, toxKeep tests in tests/ mirroring app structure.python\n# tests/test_services.py\nimport pytest\nfrom myapp.services import create_user_service\n\ndef test_create_user_success(db):\n    payload = {\"username\": \"alice\", \"email\": \"a@example.com\"}\n    user = create_user_service(payload)\n    assert user.username == \"alice\"\nDocumentationDocstrings + Sphinx or MkDocs for API; generate OpenAPI with drf‑spectacular (DRF).pydocstyleKeep README with quick‑start (virtualenv, migrations, runserver).—

2. JavaScript / TypeScript + React (web) & Node.js (backend)
QualityWhat it means in the JS ecosystemTooling / LintersKey conventionsGood vs. Bad exampleReadabilityUse ESLint with Airbnb or Standard style; enforce Prettier for formatting. Prefer explicit return statements over terse arrow‑function tricks when they hurt clarity.eslint, prettier, typescript-eslintcamelCase for vars/functions, PascalCase for React components, UPPER_SNAKE_CASE for constants.tsx\n// ❌ Over‑compact\nconst Btn = ({onClick})=> <button onClick={onClick}>Ok</button>;\n\n// ✅ Clear component name, typed props\ninterface BtnProps { onClick: () => void; }\nconst Button: React.FC<BtnProps> = ({ onClick }) => (\n  <button type=\"button\" onClick={onClick}>Ok</button>\n);\nSimplicityPrefer functional components + hooks; avoid class components unless you need legacy lifecycle. Use native array methods (map, filter, reduce) over manual loops.react-hooks/exhaustive-deps ruleKeep component files under ~200 LOC; extract reusable logic into custom hooks.tsx\n// ❌ Complex class component\nclass Counter extends React.Component {\n  state = { count: 0 };\n  inc = () => this.setState({ count: this.state.count + 1 });\n  render() { return <button onClick={this.inc}>{this.state.count}</button>; }\n}\n\n// ✅ Simple functional component + hook\nfunction Counter() {\n  const [count, setCount] = useState(0);\n  return <button onClick={() => setCount(c => c + 1)}>{count}</button>;\n}\nMaintainabilitySplit UI into presentational vs. container components (or use the “hooks‑only” pattern). Keep side‑effects in useEffect with clear dependency arrays.react-refresh for fast refresh, storybook for component isolationFolder layout: src/components/, src/hooks/, src/pages/, src/services/.tsx\n// src/components/UserCard.tsx (presentational)\nexport const UserCard = ({ user }: { user: User }) => (\n  <div>{user.name}</div>\n);\n\n// src/pages/Profile.tsx (container)\nexport const Profile = () => {\n  const user = useUser(); // custom hook that fetches data\n  return <UserCard user={user} />;\n};\nPerformanceMemoize heavy calculations with useMemo; avoid re‑creating functions with useCallback when they’re props to deep children. Lazy‑load routes (React.lazy) and split bundles (webpack/vite).webpack-bundle-analyzer, react‑profilerUse Suspense for data fetching (React 18+).tsx\n// ❌ New function each render → child re‑renders\n<button onClick={() => doSomething(item.id)}>Click</button>\n\n// ✅ useCallback memoizes handler\nconst handleClick = useCallback(() => doSomething(item.id), [item.id]);\n<button onClick={handleClick}>Click</button>\nSecurityEscape any HTML inserted via dangerouslySetInnerHTML; use CSP headers; validate/sanitize request bodies on the Node side.helmet (Express), eslint-plugin-securityNever expose secret keys in the client bundle; use dotenv on the server.js\n// ❌ Secret in client bundle\nconst MAP_API_KEY = \"abcd1234\";\n\n// ✅ Server‑side proxy\napp.get('/api/maps-token', (req, res) => {\n  res.json({ token: process.env.MAP_API_KEY });\n});\nTestingUnit test pure functions with Jest; component tests with React Testing Library; end‑to‑end with Cypress or Playwright.jest, @testing-library/react, cypressKeep tests next to the file (Component.test.tsx).tsx\n// Counter.test.tsx\nimport { render, screen, fireEvent } from '@testing-library/react';\nimport { Counter } from './Counter';\n\ntest('increments on click', () => {\n  render(<Counter />);\n  fireEvent.click(screen.getByRole('button'));\n  expect(screen.getByRole('button')).toHaveTextContent('1');\n});\nDocumentationUse Storybook for UI component docs; generate API docs from TypeScript types (typedoc).typedoc, storybookKeep README with npm install, npm run dev, npm test.—

3. Java + Spring Boot (REST APIs)
QualityJava‑specific interpretationTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Google Java Style (or Sun). Use Javadoc for public APIs. Keep methods under ~30 LOC.Checkstyle, SpotBugs, PMDcamelCase for methods/variables, PascalCase for classes, constants in UPPER_SNAKE.java\n// ❌ No Javadoc, ambiguous name\nint f(int a){ return a*a; }\n\n/**\n * Returns the square of the given integer.\n */\npublic int square(int value) {\n    return value * value;\n}\nSimplicityPrefer constructor injection over field injection; use Lombok only for boilerplate reduction, not for hiding business logic.Lombok, Error ProneKeep controllers thin – delegate to service layer.java\n// ❌ Fat controller\n@RestController\npublic class OrderController {\n    @Autowired private OrderRepository repo;\n    @PostMapping(\"/orders\")\n    public ResponseEntity<Order> create(@RequestBody OrderDto dto) {\n        // validation, mapping, persistence, email, etc – all here\n    }\n}\n\n// ✅ Thin controller + service\n@RestController\n@RequiredArgsConstructor\npublic class OrderController {\n    private final OrderService orderService;\n    @PostMapping(\"/orders\")\n    public ResponseEntity<Order> create(@RequestBody OrderDto dto) {\n        Order order = orderService.createOrder(dto);\n        return ResponseEntity.status(HttpStatus.CREATED).body(order);\n    }\n}\nMaintainabilityUse interface‑based services, DTOs for request/response, MapStruct for mapping. Separate config/, controller/, service/, repository/, domain/.Spring Boot Actuator, ArchUnit (architecture tests)Apply SOLID; avoid God classes.—PerformanceLeverage Spring’s caching abstraction (@Cacheable), async (@Async), and reactive stack (WebFlux) only when needed. Use pagination (Pageable).JMH for micro‑benchmarks, Spring Boot DevTools for live reload.Keep DB calls in one place; use @Transactional(readOnly = true) for queries.java\n// ❌ Loads all rows\nList<User> users = userRepo.findAll();\n\n// ✅ Paginated\nPage<User> users = userRepo.findAll(PageRequest.of(0, 20));\nSecurityEnable Spring Security, use BCrypt for passwords, enforce CSRF for web apps, validate JWT signatures.OWASP Dependency‑Check, SpotBugs + security pluginsExternalize secrets via application‑properties + Vault/Env vars.java\n// ❌ Plain text password\nuser.setPassword(rawPassword);\n\n// ✅ BCrypt hash\nuser.setPassword(passwordEncoder.encode(rawPassword));\nTestingUnit test services with JUnit 5 + Mockito; integration tests with @SpringBootTest and Testcontainers for DB.JUnit, Mockito, AssertJ, TestcontainersKeep test classes in src/test/java mirroring package structure.java\n@ExtendWith(MockitoExtension.class)\nclass OrderServiceTest {\n    @Mock private OrderRepository repo;\n    @InjectMocks private OrderService service;\n\n    @Test\n    void createsOrder() {\n        OrderDto dto = new OrderDto(...);\n        when(repo.save(any())).thenReturn(new Order(...));\n        Order result = service.createOrder(dto);\n        assertThat(result).isNotNull();\n    }\n}\nDocumentationGenerate OpenAPI specs with springdoc‑openapi; host Swagger UI.springdoc-openapi, asciidoctor for API guidesKeep README with ./mvnw spring-boot:run.—

4. C# + ASP.NET Core / Entity Framework
QualityC#‑specific viewTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Microsoft C# coding conventions: PascalCase for public members, camelCase for locals, _underscore prefix for private fields. Use XML doc comments (///).StyleCop.Analyzers, Roslyn analyzers, ReSharperKeep methods ≤ 30 LOC, use expression‑bodied members for trivial getters.csharp\n// ❌ No XML comment, ambiguous name\nint f(int a){ return a*a; }\n\n/// <summary>Returns the square of <paramref name=\"value\"/>.</summary>\npublic int Square(int value) => value * value;\nSimplicityPrefer record types for immutable DTOs (record UserDto(string Name, string Email);). Use minimal APIs for simple endpoints.dotnet format, dotnet analyzersAvoid heavy inheritance hierarchies; use composition.csharp\n// ❌ Verbose controller\n[ApiController]\n[Route(\"api/[controller]\")]\npublic class WeatherController : ControllerBase {\n    private readonly IWeatherService _svc;\n    public WeatherController(IWeatherService svc) { _svc = svc; }\n    [HttpGet]\n    public async Task<IActionResult> Get() => Ok(await _svc.GetAsync());\n}\n\n// ✅ Minimal API (ASP.NET 6+)\nvar app = WebApplication.CreateBuilder(args).Build();\napp.MapGet(\"/weather\", async (IWeatherService svc) => await svc.GetAsync());\napp.Run();\nMaintainabilityUse interface‑based services, keep DbContext in its own layer, apply CQRS (Command‑Query Responsibility Segregation) when the domain grows.dotnet-ef migrations, Architecture.Tests with ArchUnitNETFolder layout: Controllers/, Services/, Repositories/, Models/, Dtos/.—PerformanceEnable response compression, use async I/O (await), leverage IQueryable for deferred execution. Use MemoryCache or DistributedCache (Redis).BenchmarkDotNet for micro‑benchmarks, dotnet-traceAvoid sync over async; use ConfigureAwait(false) in library code.csharp\n// ❌ Blocking DB call\nvar users = _dbContext.Users.ToList(); // blocks thread\n\n// ✅ Async, deferred execution\nvar users = await _dbContext.Users.Where(u => u.IsActive).ToListAsync();\nSecurityASP.NET Core Identity, PasswordHasher<TUser> (PBKDF2). Enforce HTTPS, use Data Protection API for cookies.Microsoft.AspNetCore.Authentication, OWASP ZAP for scanningStore secrets in User‑Secrets, Azure Key Vault, or environment variables.csharp\n// ❌ Plain text connection string\nbuilder.Configuration[\"ConnectionStrings:Default\"] = \"Server=...;Password=secret\";\n\n// ✅ Use secret manager\nbuilder.Configuration.AddUserSecrets<Program>();\nTestingXUnit + Moq (or NSubstitute). Use WebApplicationFactory for integration tests.xunit, Moq, FluentAssertions, TestcontainersKeep test project named *.Tests.csharp\npublic class WeatherServiceTests {\n    private readonly Mock<IWeatherProvider> _provider = new();\n    private readonly WeatherService _svc;\n\n    public WeatherServiceTests() {\n        _svc = new WeatherService(_provider.Object);\n    }\n\n    [Fact]\n    public async Task ReturnsForecast() {\n        _provider.Setup(p => p.GetAsync()).ReturnsAsync(new Forecast { Temp = 23 });\n        var result = await _svc.GetAsync();\n        result.Temp.Should().Be(23);\n    }\n}\nDocumentationSwagger/OpenAPI via Swashbuckle. XML comments generate UI docs.Swashbuckle.AspNetCore, DocFX for site docsInclude versioning (/api/v1/...).—

5. Go (Golang) + Gin / Echo (web) or plain net/http
QualityGo‑specific interpretationTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Effective Go and Go 1.22 formatting (gofmt). Use short, clear names; avoid overly generic data or info.golint, staticcheck, go vetPackages are small (single responsibility); exported names start with capital letter.go\n// ❌ Vague name, no comment\nfunc f(a int) int { return a * a }\n\n// ✅ Clear, documented\n// Square returns the square of n.\nfunc Square(n int) int { return n * n }\nSimplicityPrefer composition over inheritance (no inheritance in Go). Use built‑in context.Context for request‑scoped values.goimports, gofumptUse error wrapping (fmt.Errorf(\"%w\", err)).go\n// ❌ Panics for error handling\nfunc Load() User { data, _ := ioutil.ReadFile(\"file\"); return Parse(data) }\n\n// ✅ Return error, wrap\nfunc Load() (User, error) {\n    data, err := os.ReadFile(\"file\")\n    if err != nil { return User{}, fmt.Errorf(\"read file: %w\", err) }\n    return Parse(data)\n}\nMaintainabilityKeep interfaces small; inject dependencies via function parameters. Separate handlers, services, repositories.go test -cover, golangci-lintFolder layout: cmd/ (main entry), internal/ (app code), pkg/ (re‑usable libraries).—PerformanceUse goroutine pools wisely; avoid unnecessary allocations (reuse buffers). Prefer io.Reader/Writer streaming.pprof, go tool traceCache results in memory (sync.Map or external Redis).go\n// ❌ Reads whole file into memory\ndata, _ := os.ReadFile(\"big.log\")\nprocess(data)\n\n// ✅ Stream processing\nf, _ := os.Open(\"big.log\")\ndefer f.Close()\nscanner := bufio.NewScanner(f)\nfor scanner.Scan() {\n    process(scanner.Bytes())\n}\nSecurityValidate all external input; use net/http's SecureHeaders middleware (or third‑party). Never trust X-Forwarded-For without TLS termination check.gosec, depguardStore secrets in env vars or secret managers, not in code.—TestingTable‑driven tests are idiomatic. Use httptest for HTTP handlers, testify/assert for readability.go test, gotest.tools, testifyKeep tests in same package with _test.go suffix.go\nfunc TestSquare(t *testing.T) {\n    cases := []struct{ in, want int }{{2,4},{-3,9}}\n    for _, c := range cases {\n        got := Square(c.in)\n        if got != c.want {\n            t.Fatalf(\"Square(%d)=%d, want %d\", c.in, got, c.want)\n        }\n    }\n}\nDocumentationgo doc extracts comments; generate site docs with godoc or pkgsite.godoc, goldsWrite package comments at top of each file.—

6. Rust + Actix‑Web / Rocket (backend) or no‑std embedded
QualityRust‑specific takeTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Rustfmt style; use snake_case for functions/variables, PascalCase for types, SCREAMING_SNAKE for constants. Document public items with ///.rustfmt, clippy, cargo-auditKeep functions < 40 LOC; avoid deep nesting by early returns (if cond { return; }).rust\n// ❌ No doc, cryptic name\nfn f(v: i32) -> i32 { v * v }\n\n/// Returns the square of `value`.\npub fn square(value: i32) -> i32 { value * value }\nSimplicityPrefer Result<T, E> error handling over panics; use ? operator. Prefer enum for state machines instead of bool flags.cargo clippy warnings (needless_return, match_like_if_let)Use async/await with tokio or async-std when I/O bound.rust\n// ❌ Nested match\nmatch a {\n    Ok(v) => match b {\n        Ok(w) => Ok(v + w),\n        Err(e) => Err(e),\n    },\n    Err(e) => Err(e),\n}\n\n// ✅ Using `?`\nfn add(a: Result<i32, E>, b: Result<i32, E>) -> Result<i32, E> {\n    Ok(a? + b?)\n}\nMaintainabilitySplit code into crates (libraries) for reusable pieces; keep public API small (pub(crate) vs. pub). Use traits for abstraction, not inheritance.cargo test --doc for doctests, cargo audit for dependenciesFollow semantic versioning for crates you publish.—PerformanceZero‑cost abstractions are the default; but watch for unnecessary heap allocation (Box, Vec). Use #[inline] sparingly.cargo bench, flamegraph, perfPrefer &[T] slices over Vec<T> when you don’t need ownership.rust\n// ❌ Allocates a new Vec each call\nfn sum(nums: Vec<i32>) -> i32 { nums.iter().sum() }\n\n// ✅ Borrow slice, no allocation\nfn sum(nums: &[i32]) -> i32 { nums.iter().sum() }\nSecurityThe borrow checker eliminates many classes of memory bugs; still validate external data (e.g., serde #[serde(deny_unknown_fields)]).cargo audit, cargo denyKeep secrets out of binaries; use dotenvy or OS env vars.—TestingUnit tests in mod tests { … } with #[cfg(test)]. Use property‑based testing (proptest) for edge cases.cargo test, proptestKeep integration tests in tests/ directory.rust\n#[cfg(test)]\nmod tests {\n    use super::*;\n    #[test]\n    fn square_works() {\n        assert_eq!(square(3), 9);\n    }\n}\nDocumentationcargo doc --open generates HTML from /// comments; host on docs.rs for crates.cargo doc, mdbook for larger guidesKeep a README.md with cargo commands and quick start.—

7. PHP + Laravel (or Symfony)
QualityPHP‑specific viewTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow PSR‑12 coding style; use PHPDoc blocks for functions and classes.PHP_CodeSniffer, PHPStan, PsalmcamelCase for methods/variables, PascalCase for classes, constants in UPPER_SNAKE.php\n// ❌ No doc, vague name\nfunction f($a){ return $a*$a; }\n\n/**\n * Returns the square of the given number.\n */\nfunction square(int $value): int {\n    return $value * $value;\n}\nSimplicityUse Eloquent models for simple CRUD; avoid repository pattern unless you truly need abstraction.laravel‑tinker, artisan make:modelPrefer route closures for tiny endpoints; move complex logic to Service classes.php\n// ❌ Over‑engineered controller\nclass UserController extends Controller {\n    public function store(Request $request) {\n        $repo = new UserRepository();\n        $repo->save($request->all());\n        // … many extra steps\n    }\n}\n\n// ✅ Simple controller + form request validation\nclass UserController extends Controller {\n    public function store(StoreUserRequest $request) {\n        $user = User::create($request->validated());\n        return response()->json($user, 201);\n    }\n}\nMaintainabilityKeep controllers thin; put business logic into Actions (app/Actions/). Use Form Request classes for validation.Laravel Pint (formatter), phpstan (static analysis)Directory layout: app/Models, app/Http/Controllers, app/Http/Requests, app/Actions.—PerformanceUse eager loading (with) to prevent N+1 queries, enable OPcache, cache results (Cache::remember).Laravel Telescope, BlackfireUse queues (dispatch) for long‑running tasks.php\n// ❌ N+1\n$posts = Post::all();\nforeach ($posts as $post) {\n    echo $post->author->name; // each access runs a query\n}\n\n// ✅ Eager load\n$posts = Post::with('author')->get();\nforeach ($posts as $post) {\n    echo $post->author->name; // no extra queries\n}\nSecurityEnable CSRF protection (default), use bcrypt (Hash::make) for passwords, validate input with validated() method.Laravel Security Checker, Laravel Sanctum/Passport for authStore secrets in .env; never commit it.php\n// ❌ Hard‑coded key\ndefine('API_KEY', '12345');\n\n// ✅ Env var\n$apiKey = env('API_KEY');\nTestingUse PHPUnit (bundled) + Laravel’s testing helpers (actingAs, postJson).phpunit, pestphp (optional)Keep tests under tests/Feature and tests/Unit.php\npublic function test_user_can_register()\n{\n    $response = $this->postJson('/api/register', [\n        'name' => 'Alice',\n        'email' => 'alice@example.com',\n        'password' => 'secret123',\n    ]);\n\n    $response->assertCreated();\n    $this->assertDatabaseHas('users', ['email' => 'alice@example.com']);\n}\nDocumentationUse Laravel API Resource classes for JSON responses; generate OpenAPI with scribe or l5-swagger.scribe, phpDocumentorKeep a README.md with composer install, .env.example, php artisan migrate --seed.—

8. Ruby + Rails
QualityRails‑specific practicesTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Ruby Style Guide (rubocop); use snake_case for methods/variables, CamelCase for classes/modules. Document public methods with # comments.rubocop, reek, rails_best_practicesKeep models skinny; move business logic to services or concerns.ruby\n# ❌ No comment, vague name\ndef f(a)\n  a * a\nend\n\n# ✅ Clear name, doc comment\n# Returns the square of the given integer.\ndef square(value)\n  value * value\nend\nSimplicityPrefer ActiveRecord scopes and validations; avoid unnecessary gems. Use Rails' built‑in helpers (form_with, link_to).brakeman (security), bundler-auditUse concerns for shared model logic; keep controllers thin (fat models, skinny controllers).ruby\n# ❌ Fat controller\nclass OrdersController < ApplicationController\n  def create\n    @order = Order.new(order_params)\n    if @order.valid?\n      # many lines of payment & email logic here\n    else\n      render :new\n    end\n  end\nend\n\n# ✅ Thin controller + service\nclass OrdersController < ApplicationController\n  def create\n    @order = OrderCreationService.call(order_params)\n    if @order.persisted?\n      redirect_to @order, notice: 'Created!'\n    else\n      render :new\n    end\n  end\nend\nMaintainabilityUse decorators (Draper) or presenters for view logic; keep routes RESTful; version API (/api/v1).rspec, factory_bot, shoulda-matchersFolder layout: app/models, app/controllers, app/services, app/queries, app/presenters.—PerformanceUse eager loading (includes), counter_cache, and select to fetch only needed columns. Cache fragments or whole pages (Rails.cache).rack-mini-profiler, bullet (detect N+1)Use background jobs (Sidekiq) for heavy work.```ruby\n# ❌ N+1\n@posts.each doSecurityEnable Strong Parameters, CSRF tokens (default), use has_secure_password (bcrypt).brakeman, bundler-auditStore credentials in credentials.yml.enc or environment variables (dotenv-rails).—TestingRSpec is de‑facto; use feature specs with Capybara, request specs for API.rspec-rails, capybara, factory_botKeep specs under spec/models, spec/controllers, spec/requests.ruby\nRSpec.describe 'User registration', type: :request do\n  it 'creates a new user' do\n    post '/users', params: { user: { name: 'Bob', email: 'bob@example.com', password: 'secret' } }\n    expect(response).to have_http_status(:created)\n    expect(User.last.email).to eq('bob@example.com')\n  end\nend\nDocumentationUse RDoc or YARD for code docs; generate API docs with rswag (Swagger).yard, rswagKeep README.md with bundle install, rails db:setup, rails server.—

9. Kotlin + Spring Boot (or Ktor)
QualityKotlin‑specific notesTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Kotlin coding conventions: camelCase for functions/variables, PascalCase for classes, UPPER_SNAKE for constants. Use KDoc (/** … */).detekt, ktlint, SpotBugsPrefer extension functions for reusable utilities, but keep them in appropriate packages.kotlin\n// ❌ No KDoc, ambiguous name\nfun f(a: Int) = a * a\n\n/** Returns the square of [value]. */\nfun square(value: Int): Int = value * value\nSimplicityUse data classes for DTOs, sealed classes for state machines. Prefer coroutine suspend functions over callbacks.kotlinx.coroutines, spring-boot-starter-webfluxUse constructor injection (@Autowired is rarely needed).kotlin\n// ❌ Callback hell\nfun fetchUser(id: String, callback: (User?) -> Unit) { … }\n\n// ✅ Coroutine\nsuspend fun fetchUser(id: String): User? = userRepository.findById(id)\nMaintainabilityKeep service interfaces separate from implementations; use Spring's @Service with clear responsibilities.archunit for architecture testsPackage by feature (e.g., order/, customer/) rather than by layer.—PerformanceKotlin’s inline functions (inline) avoid lambda allocation; use Flow for reactive streams when needed.jmh (Java Microbenchmark Harness)Avoid unnecessary boxing (Int vs. Int?).kotlin\n// ❌ Boxing overhead\nfun sum(values: List<Int?>): Int = values.filterNotNull().sum()\n\n// ✅ Primitive array avoids boxing\nfun sum(values: IntArray): Int = values.sum()\nSecurityLeverage Spring Security; use PasswordEncoder (BCryptPasswordEncoder).dependency-check, OWASP Dependency‑CheckKeep secrets out of application.yml (use spring.config.import=optional:configtree:/secrets/).—TestingJUnit 5 + MockK (or Mockito‑Kotlin). Use @WebMvcTest for controller slices, @DataJpaTest for repository tests.kotest, mockk, spring-boot-testWrite parameterized tests with @CsvSource.kotlin\nclass UserServiceTest {\n    @MockK lateinit var repo: UserRepository\n    lateinit var service: UserService\n\n    @BeforeEach fun setUp() { MockKAnnotations.init(this); service = UserService(repo) }\n\n    @Test fun `creates user with hashed password`() {\n        every { repo.save(any()) } answers { firstArg() }\n        val user = service.register(\"alice\", \"plain\")\n        assertTrue(passwordEncoder.matches(\"plain\", user.password))\n        verify { repo.save(any()) }\n    }\n}\nDocumentationUse SpringDoc OpenAPI (springdoc-openapi-ui) for Swagger UI; generate Kotlin docs with Dokka.dokka, springdoc-openapiKeep README.md with Gradle wrapper commands (./gradlew bootRun).—

10. Swift + iOS (UIKit / SwiftUI)
QualitySwift‑specific viewTooling / LintersKey conventionsGood vs. Bad exampleReadabilityFollow Swift API Design Guidelines: method names read like sentences, parameters labeled. Use /// for documentation.SwiftLint, Xcode static analyzercamelCase for methods/variables, PascalCase for types, UPPER_SNAKE for constants.swift\n// ❌ Vague, no doc\nfunc f(_ a: Int) -> Int { a * a }\n\n/// Returns the square of `value`.\nfunc square(of value: Int) -> Int { value * value }\nSimplicityPrefer structs for value types, enum with associated values for state. Use @State/@Binding in SwiftUI rather than manual delegation.Xcode Previews, Combine for reactive streamsKeep view bodies small; extract sub‑views.swift\n// ❌ Huge SwiftUI view\nvar body: some View {\n    VStack { /* 200 lines of UI */ }\n}\n\n// ✅ Split into components\nstruct ProfileHeader: View { … }\nstruct ProfileView: View { var body: some View { VStack { ProfileHeader(); … } } }\nMaintainabilityUse MVVM or VIPER for larger apps; keep networking in dedicated services.Fastlane for CI, SwiftGen for assets & stringsGroup files by feature (e.g., Login/, Home/).—PerformanceLeverage lazy collections, avoid heavy work on main thread (DispatchQueue.global().async). Use * Instruments* to detect leaks & CPU spikes.Instruments, Xcode AnalyzerCache images with NSCache or SDWebImage.swift\n// ❌ Blocking main thread\nlet data = try! Data(contentsOf: url) // sync network\nimageView.image = UIImage(data: data)\n\n// ✅ Async fetch\nURLSession.shared.dataTask(with: url) { data, _, _ in\n    guard let data = data else { return }\n    DispatchQueue.main.async { imageView.image = UIImage(data: data) }\n}.resume()\nSecurityUse Keychain for credentials, enable App Transport Security (HTTPS only).SwiftLint rule for hard‑coded secrets, OWASP Mobile Security Project checklistDo not store plain passwords; use Biometric authentication (LocalAuthentication).—TestingXCTest + XCUITest for UI; use Quick/Nimble for BDD style if preferred.XCTest, XCUITest, Fastlane for test automationKeep unit tests in Tests/ target, UI tests in UITests/.swift\nfunc testSquareFunction() {\n    XCTAssertEqual(square(of: 3), 9)\n    XCTAssertEqual(square(of: -4), 16)\n}\nDocumentationUse DocC (Xcode 13+) to generate documentation bundles; keep a README with xcodebuild commands for CI.jazzy (alternative)Document public APIs, provide sample usage snippets.—

How to Use This Cheat‑Sheet

1. Pick your stack – locate the table that matches your language/framework.
2. Adopt the “Tooling / Linters” column first; a CI pipeline that runs the linter, formatter, and static analysis catches many problems automatically.
3. Apply the “Key conventions” to your project skeleton (folder layout, naming).
4. Copy the “Good vs. Bad” snippets as templates for new code.
5. Integrate the testing and documentation practices early; they pay off the most when the code base grows.

Feel free to ask for deeper dive‑levels (e.g., “How to structure a large React + Redux code‑base?” or “Best practices for micro‑services in Spring Boot”). Happy coding!

////////////////////////////////////////////////////////

Below is a quick‑reference cheat sheet that drills down into the “extra‑specific” details you’ll want to keep in mind for each major language and its most‑used frameworks.  Think of it as a checklist you can copy‑paste into a project‑setup document or a personal wiki.

1. JavaScript / TypeScript
ContextExtra‑Specific TipsNode.js (plain)• Use ESM ("type": "module" in package.json) unless you need legacy CommonJS. • Pin the Node version in engines and lock it with nvm/volta. • Prefer async/await over raw promises for readability; wrap top‑level calls in an IIFE.React• Keep components pure – avoid side‑effects in render. • Use useCallback / useMemo only when you can prove a measurable re‑render cost. • Enforce prop‑type or TypeScript interfaces; treat any as a lint error. • Adopt file‑based routing (e.g., Next.js) or component‑folder pattern (Component/Component.tsx, Component/styles.module.css).Angular• Enable strict mode (ng new --strict). • Use OnPush change detection for all components unless you need default. • Keep services singleton (providedIn: 'root') and avoid stateful logic in components. • Leverage Angular CLI schematics for generating modules, guards, and resolvers.Vue 3• Prefer Composition API (setup()) for reusable logic. • Use <script setup> syntax for single‑file components to reduce boilerplate. • Enable defineProps and defineEmits with TypeScript for strict typing. • Keep store (Pinia/Vuex) logic out of components; use modules for domain separation.Testing• Jest + React Testing Library / Vue Test Utils / Angular TestBed. • Enforce 100 % unit coverage on utility functions; ≥80 % on components. • Use msw (Mock Service Worker) for API mocking in integration tests.Build / Deploy• Use esbuild or swc for fast transpilation in CI. • Generate source maps only for staging, never production. • Set Content‑Security‑Policy headers and enable Subresource Integrity for CDN assets.

2. Python
ContextExtra‑Specific TipsCore / Scripts• Pin the interpreter (python==3.12) in pyproject.toml or requirements.txt. • Use __future__ imports (annotations) for forward‑compatible typing. • Run ruff (fast linter) + black (formatter) in pre‑commit.Django• Enable django-stubs for static typing (mypy). • Keep settings split: base.py, dev.py, prod.py; never commit secret keys. • Use django-environ or python-decouple for env‑var handling. • Run django‑admin startapp with a services/ folder for business logic (avoid fat models).Flask• Adopt application factory pattern (create_app) for testability. • Register blueprints per domain (e.g., auth, api/v1). • Use flask‑sqlalchemy + alembic for migrations; keep migration scripts in migrations/.FastAPI• Leverage Pydantic v2 models for request/response validation. • Use dependency injection (Depends) for DB sessions, auth, etc. • Enable --reload only in dev; use Uvicorn/Gunicorn workers in prod (workers = (cpu * 2) + 1).Testing• pytest + pytest‑asyncio for async endpoints. • Use fixtures for DB rollbacks (session scope). • Enforce type‑checking (mypy --strict) in CI.Packaging• Prefer PEP 517 (pyproject.toml) over setup.py. • Publish wheels (.whl) to an internal PyPI repo for faster installs.

3. Java
ContextExtra‑Specific TipsCore / Maven• Use Maven Wrapper (mvnw) to lock the Maven version. • Enforce maven-enforcer-plugin for Java version and dependency convergence.Spring Boot• Enable spring-boot-devtools only in dev profile. • Use @ConfigurationProperties with @ConstructorBinding for immutable config. • Prefer Lombok (@Getter/@Setter) but keep a delomboked source for IDEs that don’t support it. • Separate application.yml per profile (application-dev.yml, application-prod.yml).Jakarta EE• Use jakarta.* packages (post‑Java EE) and upgrade to Servlet 6+. • Keep EJB usage minimal; favor CDI (@Inject).Testing• JUnit 5 + @ExtendWith(SpringExtension.class). • Use Testcontainers for integration tests (real DB, Kafka, etc.). • Enforce spotbugs and checkstyle in CI.Build / Deploy• Build thin JAR (spring-boot:repackage) for Docker; keep layered JAR for faster rebuilds. • Use jlink to create a custom runtime image if you need minimal footprint.

4. C# / .NET
ContextExtra‑Specific Tips.NET 8 (LTS)• Target net8.0 in all projects; use global.json to lock SDK version.ASP.NET Core• Enable IOptions<T> with ValidateDataAnnotations for config validation. • Use minimal APIs for simple services; keep controllers for complex domains. • Register ILogger<T> via DI; avoid static loggers.Entity Framework Core• Use HasNoKey() for query‑type (read‑only) entities. • Apply DbContextFactory for background services to avoid thread‑safety issues.Blazor• Prefer @code block with partial class for large components. • Use IJSRuntime wrappers for JS interop; keep them in a Services/ folder.Testing• xUnit + Microsoft.AspNetCore.Mvc.Testing for integration tests. • Use dotnet test --collect:"XPlat Code Coverage" and enforce ≥80 % coverage.CI/CD• Use dotnet publish -c Release -o out; then multi‑stage Docker (sdk → runtime). • Enable Ready‑to‑Run compilation (PublishReadyToRun=true) for faster startup.

5. Ruby
ContextExtra‑Specific TipsRuby 3.3• Enable --enable-frozen-string-literal (# frozen_string_literal: true).Rails 7+• Use importmap or esbuild for JS bundling; avoid the old asset pipeline for new apps. • Keep app/services for business logic; app/models should be thin. • Enable config.load_defaults 7.1 and config.autoloader = :zeitwerk.Sinatra• Use Rack::Protection middleware for security. • Separate routes into modular apps (class API < Sinatra::Base).Testing• RSpec + factory_bot + shoulda-matchers. • Use rails test:system with Capybara for end‑to‑end.Deployment• Use puma with workers = ENV.fetch("WEB_CONCURRENCY") { 2 } and threads = 5, 5. • Enable rails db:prepare in Docker entrypoint to run migrations automatically.

6. Go
ContextExtra‑Specific TipsModules• Always use go.mod with a semantic version (v0.1.0). • Run go mod tidy before committing.Gin• Use gin.Recovery() middleware for panic handling. • Bind JSON with ShouldBindJSON and validate via go-playground/validator.Echo• Enable Echo#HideBanner and Echo#HidePort for production.Testing• go test ./... -coverprofile=coverage.out + go tool cover -html=coverage.out. • Use testify/assert for expressive assertions.Build• Build with -ldflags "-s -w" to strip debug info. • Use CGO_ENABLED=0 for static binaries when possible.CI• Run golangci-lint run in CI; treat any warning as a failure.

7. PHP
ContextExtra‑Specific TipsPHP 8.3• Enable strict_types=1 at the top of every file.Laravel 11• Use php artisan make:service (via a custom stub) to keep business logic out of controllers. • Store config in .env and never commit it; use config:cache for production. • Enable queue:work --daemon with Supervisor for background jobs.Symfony 7• Use maker bundle to generate DTOs and EventSubscribers. • Keep services private by default; expose only what’s needed via autowiring.Testing• PHPUnit + pestphp/pest for a more expressive syntax. • Run phpstan (level 9) and psalm in CI.Deployment• Use php-fpm with opcache enabled (opcache.validate_timestamps=0). • Serve static assets via a CDN; set Cache-Control: max-age=31536000, immutable.

8. TypeScript (Server‑side)
ContextExtra‑Specific TipsNestJS• Enable strict mode in tsconfig.json. • Use @Injectable({ scope: Scope.REQUEST }) only when you truly need per‑request state. • Keep DTOs separate from entities; use class‑validator for input validation.Deno• Use deno lint and deno fmt; lock dependencies with import_map.json.Testing• jest + ts-jest; set isolatedModules: true to catch type‑only imports. • Enforce 100 % coverage on utility modules.

How to Use This Cheat Sheet

1. Copy the relevant table into your project’s README.md or internal wiki.
2. Add a pre‑commit hook (e.g., via husky for JS, pre-commit for Python) that runs the linters/formatters listed.
3. In CI, fail fast on any of the “must‑have” items (e.g., missing strict mode, no Content‑Security‑Policy).
4. Periodically review the table when upgrading language versions or adding new frameworks.


Quick “One‑Liner” Checklist (All Projects)
[ ] Language version locked (nvm/pyenv/rbenv/rvm/volta/etc.)
[ ] Strict/typed mode enabled (TS strict, Python mypy, Java -Xlint, Go vet)
[ ] Linter + formatter in pre‑commit
[ ] CI runs: lint → type‑check → unit tests → coverage → security scan
[ ] Secrets never in repo (use env vars / secret manager)
[ ] Dockerfile uses multi‑stage build, minimal runtime image
[ ] Production config: CSP, HSTS, secure cookies, no debug flags
[ ] Monitoring/metrics wired (Prometheus, New Relic, etc.)

Feel free to cherry‑pick the rows that apply to your stack, and expand any cell with project‑specific commands or scripts. Happy coding!
