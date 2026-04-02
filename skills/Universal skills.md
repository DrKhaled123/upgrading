Universal skills.md

Great questions — both are deeply connected to how Claude's skill/memory system works. Let me break this down clearly.

---
## Question 1: How to Put High-Quality Data in Claude's Memory & System Instructions

There are **3 layers** you can use:

### Layer 1 — System Prompt (Operator Level)
This is the most powerful. If you're using the **API or a custom Claude deployment**, you write a `system` prompt that Claude reads at the start of every conversation. This is where you put:
- Coding philosophy & standards
- Persona rules ("You are an elite senior engineer...")
- Default behaviors ("Always write tests first")
- Constraints ("Never use `any` in TypeScript")

### Layer 2 — Claude's Memory Feature (claude.ai)
In claude.ai settings, **Memory** can be enabled. Claude generates memory entries from conversations. You can also **manually write memories** by telling Claude:
> *"Remember that my project uses X stack, Y conventions, Z rules."*

Claude stores these and recalls them in future chats. Best for: personal preferences, project context, recurring patterns.

### Layer 3 — Skill Files (The Power Move — your Question 2)
This is the `/mnt/skills/` system you see in this environment. Skills are **SKILL.md files** that Claude reads on demand before executing a task. This is the correct answer for your 10,000-line bug-fixing instruction set.
---
## Question 2: Writing a Comprehensive Bug-Fixation Skill (10,000-Line VIP Notes)

Here's the **exact architecture** you should follow:

### Skill File Structure

```
/mnt/skills/
  └── bugs/
        ├── SKILL.md              ← Master router (trigger descriptions + index)
        ├── 01_diagnosis.md       ← Bug detection, root cause analysis
        ├── 02_test_strategy.md   ← Test writing, coverage, edge cases
        ├── 03_fix_patterns.md    ← Fix patterns by bug category
        ├── 04_code_quality.md    ← Clean code standards post-fix
        ├── 05_advanced_bugs.md   ← Race conditions, memory leaks, etc.
        └── examples/
              ├── react_bugs.md
              ├── python_bugs.md
              └── api_bugs.md
```
### SKILL.md Master File (what triggers Claude to load it)

```markdown
# Bug Fixation Skill — Master Index

## Trigger Conditions
Load this skill when the user asks to:
- Fix a bug, error, or unexpected behavior
- Debug any code
- Write tests for broken code
- Analyze a stack trace or error log
- Review code for potential issues

## Loading Protocol
1. Read this file first
2. Load the relevant sub-module based on bug type:
   - Diagnosis unknown → load 01_diagnosis.md
   - Need tests → load 02_test_strategy.md
   - Fix pattern needed → load 03_fix_patterns.md
   - Post-fix quality → load 04_code_quality.md
   - Advanced/tricky bug → load 05_advanced_bugs.md

## Golden Rules (Always Active)
- Never fix symptoms — fix root causes
- Always write a failing test BEFORE the fix
- Verify fix doesn't break adjacent code
- Document WHY the bug existed
```
### What to Put in Each Sub-Module

**`01_diagnosis.md`** — Bug Detection Engine
```markdown
## Step 1: Reproduce Before Touching Anything
- Get exact reproduction steps
- Identify: is this deterministic or flaky?
- Capture: input → expected → actual

## Step 2: Isolation Protocol
- Binary search the codebase (comment half out)
- Check last git diff first
- Trace data flow from entry point

## Step 3: Root Cause Categories
| Category | Signals | First Check |
|----------|---------|-------------|
| State mutation | Works first time, breaks on repeat | Shared mutable state |
| Async race | Intermittent, timing-dependent | Promise chains, useEffect deps |
| Type coercion | Works in dev, fails in edge case | == vs ===, null/undefined |
| Memory leak | Slows over time | Event listeners, subscriptions |
| Off-by-one | Array/loop bugs | Index 0 vs 1, < vs <= |
```

**`02_test_strategy.md`** — High-Value Test Writing
```markdown
## Test Hierarchy (write in this order)
1. Regression test that FAILS on the bug
2. Unit test for the isolated function
3. Integration test for the flow
4. Edge case tests (null, empty, max values)

## Test Quality Checklist
- [ ] Test name describes BEHAVIOR not implementation
- [ ] One assertion per concept
- [ ] Uses realistic data, not "foo"/"bar"
- [ ] Tests failure path, not just happy path
- [ ] No logic inside tests (no if/for)
```
---

## Recommended Workflow to Build Your Full 10,000-Line Skill
Here's the practical plan:

| Phase | Action |
|-------|--------|
| **1. Outline** | Define all bug categories you want covered |
| **2. Write SKILL.md** | Master trigger + routing logic |
| **3. Write sub-modules** | One per major topic, 500–2000 lines each |
| **4. Add code examples** | Real patterns Claude should replicate |
| **5. Add anti-patterns** | Show what NOT to do + why |
| **6. Test with Claude** | Run real bug scenarios, refine |

---

## For Your Specific Goals

**Goal 1 — Best code from first time:**
→ Put this in the **system prompt**: coding standards, stack specifics, forbidden patterns, mandatory structures.

**Goal 2 — Best bug finding + testing + fixing:**
→ Put this in a **skill file** with the architecture above. The more concrete examples (real code patterns, real anti-patterns), the better Claude performs.
---
