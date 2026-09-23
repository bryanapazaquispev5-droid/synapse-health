---
name: aider-commit
description: >-
  Aider + Gitmoji automated git commit protocol. Analyzes the staged git diff line-by-line before writing any commit message, creating a Conventional Commit header with semantic Gitmojis and an exhaustive, bulleted technical description strictly in English.
---

# Aider + Gitmoji Git Commit Protocol (Diff-Driven, Gitmoji & English Only)

Based on [aider-chat/aider](https://github.com/aider-chat/aider), [gitmoji](https://gitmoji.dev/), and [Conventional Commits](https://www.conventionalcommits.org/), this skill mandates that the AI agent inspects the actual `git diff` before generating structured, emoji-enhanced, detailed commit messages strictly in **English**.

---

## 1. Mandatory Pre-Commit Diff Analysis

Whenever drafting or executing a git commit, the agent MUST follow these steps:

1. **Inspect Changes via Git Diff:**
   * Run `git status -s` to list all modified, added, or deleted files.
   * Run `git diff --staged` (or `git diff`) to examine line-by-line additions, deletions, and structural alterations.
2. **Semantic & Gitmoji Classification:**
   * Determine the **type** (`feat`, `fix`, `refactor`, `sec`, `perf`, `style`, `test`, `chore`, `docs`).
   * Match the corresponding **Gitmoji** (e.g. `✨`, `🐛`, `♻️`, `🔒`, `⚡`, `🎨`, `🧪`, `🔧`, `📝`).
   * Determine the **scope** (`auth`, `quizzes`, `profile`, `core`, `api`, `navigation`, etc.).
3. **Draft Detailed Commit (Strictly in English):**
   * **Subject line:** `<type>(<scope>): <gitmoji> <concise imperative summary in English>` (max 65 chars).
   * **Blank line**.
   * **Detailed Body with Bullet Points (`- `):** Exhaustive breakdown in English covering:
     * Specific functional and visual changes implemented.
     * Underlying architectural, state management, or controller refactoring.
     * Security enhancements, hardware storage encryption, and data validations.
     * Code analysis and test suite verification results (e.g., `flutter analyze`, `npm test`).
4. **Execute Commit:**
   * Commit the changes using the full multi-line formatted message.

---

## 2. Commit Message Template (English + Gitmoji)

```text
<type>(<scope>): <emoji> <concise imperative summary>

- Implement <feature/change> to enable <purpose>.
- Refactor <controller/widget/service> to decouple <component> and maintain atomic single responsibility.
- Apply <security/validation/storage> to protect <data/endpoint>.
- Verify 0 issues with static analysis and automated test suites.
```

---

## 3. Standard Gitmoji Mapping
* `feat`: ✨ (`:sparkles:`) Introduce new features or capabilities.
* `fix`: 🐛 (`:bug:`) Fix a bug or defect.
* `refactor`: ♻️ (`:recycle:`) Refactor code without changing external behavior.
* `sec`: 🔒 (`:lock:`) Fix security vulnerabilities, secure storage, encryption.
* `perf`: ⚡ (`:zap:`) Improve performance, optimize queries, reduce latency.
* `style`: 🎨 (`:art:`) Improve structure/format of the code, UI styling.
* `test`: 🧪 (`:test_tube:`) Add, update, or pass tests.
* `chore`: 🔧 (`:wrench:`) Build process, tooling, dependency updates.
* `docs`: 📝 (`:memo:`) Add or update documentation.
