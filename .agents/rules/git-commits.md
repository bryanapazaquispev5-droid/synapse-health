# Aider + Gitmoji Commit Rules & Protocol (Diff-Driven, Gitmoji & English Only)

When drafting, formatting, or creating Git commits across any workspace or project, the agent MUST strictly enforce this protocol:

## 1. Mandatory Pre-Commit Diff Inspection
Before writing the commit title or message body:
1. Run `git status -s` to inspect all staged and modified files.
2. Run `git diff --staged` (or `git diff`) to review exact line additions, removals, refactorings, and logic updates.
3. Classify the change into its Conventional Commit `<type>`, matching `<gitmoji>`, and `<scope>`.

## 2. Commit Message Language Requirement
- **Commits must ALWAYS be written in ENGLISH.**
- Never write commit headers or commit descriptions in Spanish or any other language, even if the chat conversation is conducted in Spanish.

## 3. Commit Structure & Granular Bulleted Description
Every commit must follow this exact hybrid format:

```text
<type>(<scope>): <emoji> <concise imperative summary in English, max 65 chars>

- Implement <feature/change details> to enable <specific functionality/behavior>.
- Refactor <controller/widget/service/module> to ensure atomic decomposition and clean architecture.
- Add/Update <validation/security/types> to prevent <edge-case/vulnerability>.
- Verify 0 errors with static analysis and test suite execution.
```

## 4. Conventional Types & Gitmoji Mapping
- `feat`: ✨ (`:sparkles:`) New feature or user-facing capability.
- `fix`: 🐛 (`:bug:`) Bug fix, error handling correction, or patch.
- `refactor`: ♻️ (`:recycle:`) Internal code restructuring without altering observable behavior.
- `sec`: 🔒 (`:lock:`) Security improvements, token handling, keystore encryption, OWASP hardening.
- `perf`: ⚡ (`:zap:`) Performance optimizations, caching, payload minimization.
- `style`: 🎨 (`:art:`) Linting, UI/code styling, formatting consistency.
- `test`: 🧪 (`:test_tube:`) Adding, updating, or fixing unit/integration/widget tests.
- `chore`: 🔧 (`:wrench:`) Tooling, build configuration, dependency upgrades.
- `docs`: 📝 (`:memo:`) Documentation updates or additions.
