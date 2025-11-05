# Implementation Best Practices

These rules ensure maintainability, safety, and developer velocity.
**MUST** rules are enforced by CI; **SHOULD** rules are strongly recommended.

## Before Coding

- **(MUST)** Ask the user clarifying questions
- **(MUST)** Revisit if all questions are answered
- **(SHOULD)** Draft and confirm an approach for complex work
- **(SHOULD)** If ≥ 2 approaches exist, list clear pros and cons
- **(SHOULD)** If you don't agree with the instructions, present an alternative and confirm. Follow the instructions if confirmed.
- **(SHOULD)** code consistent with rest of codebase, introduce minimal changes and reuses existing code
- **(SHOULD)** Search for `.md` files for documentation.

## While Coding

- **(MUST)** Follow TDD: scaffold stub -> write failing test -> implement
- **(SHOULD)** Use lean code: Minimal repetition, composable functions, self-documenting
- **(SHOULD)** Choose libraries and frameworks that are actively maintained and widely supported
- **(SHOULD)** Keep dependencies minimal and explain why each one is used
- **(SHOULD)** Keep the code simple and readable
- **(SHOULD)** When possible, make features configurable and extensible.
- **(SHOULD)** Avoid hardcoded values; use configuration files, environment variables
- **(SHOULD)** Split large features into smaller, logical commits or steps.
- **(SHOULD)** Name functions/variables with existing domain vocabulary for consistency
- **(SHOULD)** Prefer simple, composable, testable functions
- **(SHOULD)** Review if a common DSA would make code more robust
- **(SHOULD)** Never expose secrets, keys, or credentials
- **(SHOULD)** Keep functions short and focused on one task
- **(SHOULD)** Use meaningful variable and function names
- **(SHOULD)** Handle errors gracefully, don't assume happy paths
- **(SHOULD)** Comment when code isn't self-explanatory.
- **(SHOULD)** Always double-check you implemented everything you have been asked.


## After Coding

- **(MUST)** Use the branch name in the start of the commit message and Conventional Commits format.
- **(SHOULD)** Try to have 100% Test Coverage Unit, use ignore if it's not possible
- **(SHOULD)** Prefer integration tests over heavy mocking
- **(SHOULD)** After a change, run lint, tests, and if applicable build/start the application using docker
- **(SHOULD)** Keep docs synchronized with code changes
- **(SHOULD)** Not refer to Claude or Anthropic in commit messages (but keep the co-authoring).
- **(SHOULD)** The PR description should clearly indicate what's being done any why. It should be a summary of the changes made.
- **(SHOULD)** Verify basic code style (indentation, line length, spacing).
