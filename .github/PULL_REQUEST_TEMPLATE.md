## What & why

<!-- One or two sentences. Link the spec this implements. -->

**Spec**: `specs/<feature-slug>/spec.md`
**Jira**: JIRA-xxx <!-- see .specify/templates/tasks-template.md § Jira Convention -->

## Constitution compliance

<!-- See .specify/memory/constitution.md — this is the PR-time check for the gates
     that table lists. Don't check a box you haven't actually verified. -->

- [ ] Coverage ≥ 80% on new/changed code (CI-enforced, but confirm you looked)
- [ ] SAST + dependency scan clean, or findings triaged with a reason below
- [ ] If this changes architecture: `architecture/workspace.dsl` updated, and an ADR
      added under `architecture/decisions/` if it deviates from the reference pattern
- [ ] Tests exist for the behavior this PR adds or changes
- [ ] No secrets, credentials, or PII/sensitive data in code, logs, or prompts

## Human gate

<!-- Per the constitution: PR approval is a human gate, not a rubber stamp on an
     AI pre-screen. Reviewer — you're confirming you understand and own this change. -->

- [ ] I (the reviewer) have read the diff, not just the description

## Notes for the reviewer

<!-- Anything non-obvious: trade-offs made, things deliberately left out of scope,
     open questions. -->
