---
name: git-commit
description: Create well-structured git commits following Conventional Commits specification. Use when the user wants to commit changes, stage files, or create staged commits for multiple unrelated changes.
license: MIT
compatibility: Requires git CLI.
metadata:
  author: cultainer
  version: "1.0"
---

Create git commits following the [Conventional Commits](https://www.conventionalcommits.org/) specification.

**Input**: The user may provide a description of changes, or ask to commit all/specific changes.

---

## Conventional Commits Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Allowed Types**
| Type | Description |
|------|-------------|
| `feat` | A new feature |
| `fix` | A bug fix |
| `docs` | Documentation only changes |
| `style` | Changes that do not affect the meaning of the code (white-space, formatting) |
| `refactor` | A code change that neither fixes a bug nor adds a feature |
| `perf` | A code change that improves performance |
| `test` | Adding missing tests or correcting existing tests |
| `build` | Changes that affect the build system or external dependencies |
| `ci` | Changes to CI configuration files and scripts |
| `chore` | Other changes that don't modify src or test files |
| `revert` | Reverts a previous commit |

**Scope**: A noun describing the section of the codebase (e.g., `api`, `auth`, `ui`, `core`)

**Breaking Changes**: Add `!` after type/scope: `feat!:` or `feat(api)!:`

---

## Steps

1. **Check current changes**
   ```bash
   git status
   ```

2. **Review the changes**
   ```bash
   git diff --cached --stat   # staged changes
   git diff --stat            # unstaged changes
   ```
   
   If needed, read specific files to understand the changes:
   ```bash
   git diff <file>
   ```

3. **Analyze and group changes**
   
   Determine if changes should be:
   - **Single commit**: All changes are related to one feature/fix
   - **Staged commits**: Multiple unrelated changes that should be split

4. **Stage files**
   
   For single commit:
   ```bash
   git add <files>
   # or
   git add .
   ```
   
   For staged commits, group by feature/type:
   ```bash
   git add src/feature-a/*.dart tests/feature_a_test.dart
   ```
   
   For partial file staging:
   ```bash
   git add -p <file>   # stage specific hunks
   ```

5. **Verify staged changes**
   ```bash
   git diff --cached
   ```

6. **Commit with proper message**
   ```bash
   git commit -m "$(cat <<'EOF'
   <type>(<scope>): <short description>

   <body - explain what and why, not how>

   EOF
   )"
   ```

7. **Repeat for additional commits** (if staged commits workflow)

---

## Staged Commits Workflow

When there are multiple unrelated changes, split them into separate commits:

1. **List all modified files**
   ```bash
   git diff --name-only
   ```

2. **Identify logical groups**
   - Group by feature: files that implement the same feature
   - Group by type: separate `feat`, `fix`, `refactor`, `docs`, `test`
   - Group by scope: changes to different modules

3. **Commit each group separately**
   ```bash
   # Group 1: Feature
   git add lib/features/auth/*.dart test/auth_test.dart
   git commit -m "feat(auth): implement OAuth2 login flow"

   # Group 2: Bug fix
   git add lib/core/utils/format.dart
   git commit -m "fix(utils): handle empty string in format function"

   # Group 3: Documentation
   git add docs/*.md README.md
   git commit -m "docs: update API documentation"
   ```

---

## Examples

**Simple commit:**
```
feat(auth): add OAuth2 login support
```

**With body:**
```
fix(api): resolve race condition in user creation

The previous implementation could create duplicate users when
concurrent requests arrived. Added database-level unique constraint
and proper error handling.
```

**Breaking change:**
```
feat(api)!: change authentication header format

BREAKING CHANGE: Authorization header now requires 'Bearer ' prefix.
Clients must update their authentication logic accordingly.
```

---

## Best Practices

- Use **imperative mood**: "add" not "added" or "adds"
- **Don't capitalize** the first letter of description
- **No period** at the end of the subject line
- Keep subject line **under 50 characters**
- Wrap body at **72 characters**
- Use the body to explain **what** and **why**, not how
- **NO emojis** in commit messages

---

## Guardrails

- Always run `git status` first to understand the current state
- Review changes with `git diff` before committing
- Ask the user if unsure whether to split into multiple commits
- Verify staged changes with `git diff --cached` before committing
- Do NOT commit without user confirmation if there are uncommitted changes that might be missed
