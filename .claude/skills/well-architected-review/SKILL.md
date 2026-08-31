---
name: "well-architected-review"
description: "Review a feature's plan.md against the AWS Well-Architected Framework's six pillars and produce a risk-flagged findings file. Use after /speckit-plan, before /speckit-tasks."
argument-hint: "Optional: a pillar to focus on (e.g. security, cost) — defaults to all six"
compatibility: "Requires spec-kit project structure with .specify/ directory and an existing plan.md"
metadata:
  author: "antlerbio"
  source: "AntlerBio-authored, not part of upstream github/spec-kit"
user-invocable: true
disable-model-invocation: false
---

## Purpose

This is a **design-time, human-owned architecture review**, not spec-quality validation and
not an automated gate. It answers one question: does this plan's design hold up against
AWS's own best-practice framework, given what AntlerBio is actually building on (S3 +
Lake Formation, Nextflow on AWS Batch, Bedrock agents, SageMaker — see the constitution's
Architecture Constraints table)?

**What this is not:**

- Not `/speckit-checklist`. That command validates whether the *requirements are written
  clearly*. This command validates whether the *design is sound*. Different question,
  different artifact — this does not live under `checklists/`.
- Not a CI gate. Nothing here runs automatically on commit. A future tier can add static
  IaC scanning (Checkov, cfn-guard, tfsec) once there is infrastructure code to scan —
  that is a distinct, not-yet-built mechanism, and this skill does not claim to be it.
- Not a substitute for a real AWS Well-Architected Review. That's the human-facilitated
  workshop an AWS Solutions Architect runs (often free via AWS Activate for a startup this
  size) — the right move at a real milestone, not on every feature.

## Pre-Execution Checks

Run `.specify/scripts/bash/check-prerequisites.sh --json` from the repo root and parse the
JSON for `FEATURE_DIR`. If `FEATURE_DIR/plan.md` does not exist, stop and tell the user to
run `/speckit-plan` first — there is nothing to review yet.

## Execution Steps

1. **Load context**: Read `FEATURE_DIR/plan.md` (required), `FEATURE_DIR/spec.md` if present,
   and `.specify/memory/constitution.md` for the Architecture Constraints table and the
   Core Principles (particularly II, III, IV, V).

2. **Determine scope**: If `$ARGUMENTS` names one or more pillars, review only those. Otherwise
   review all six.

3. **For each in-scope pillar, evaluate the plan against it** — not generic boilerplate
   questions, but findings grounded in what this specific plan actually proposes. Use the
   prompts below as a starting point and extend them where the plan raises something they
   don't cover.

   **Operational Excellence** — Is there a way to observe this component running (structured
   logs, CloudWatch alarms, a dashboard) or does a failure require someone reading raw logs
   cold? Is the change reversible in production (feature flag, additive migration, blue/green)
   per Principle V? Is there a runbook, or does this depend on tribal knowledge?

   **Security** — Does this touch PII or proprietary omics/phenomics data, and is that
   classification stated anywhere? Is access scoped to a specific least-privilege role, not a
   shared broad one, per Principle IV? If this plan involves a Bedrock agent, are guardrails
   configured for PII or external input, as the constitution requires? Do secrets live in
   Secrets Manager/KMS, never in code, config, or prompts?

   **Reliability** — What is the blast radius if this component fails — does it take the
   pipeline down, the API down, or only itself? Is there retry/backoff for transient AWS
   failures (Batch job failure, Bedrock throttling, Glue crawler timeout)? Is a single point
   of failure being accepted here, and if so, is that written down as an ADR or just implied?

   **Performance Efficiency** — Is compute sizing (Batch job, SageMaker instance type, Lambda
   memory) based on an actual estimate, or a guess to be revisited later? Does this plan
   introduce a new data-lake access pattern that Lake Formation/Glue permissions need to
   account for?

   **Cost Optimization** — Is model tiering applied per Principle V — cheap models for
   mechanical work, frontier models reserved for judgment calls? Is anything provisioned to
   run continuously that could be on-demand, spot, or scheduled? Does new data get a storage
   lifecycle policy (bronze/silver/gold tiering), or does it default to hot storage forever?

   **Sustainability** — Is compute scoped to actual need, with no idle GPU or instance time
   built into the design? Is data retained only as long as it is useful, with a deletion or
   archival path defined?

4. **Classify each finding**: `High risk`, `Medium risk`, `Low risk`, or `Not applicable`,
   matching the terms AWS's own Well-Architected Tool uses (HRI / MRI). A finding needs a
   one-line reason, not just a label.

5. **Route unresolved risk**: Every `High risk` or `Medium risk` finding needs either an
   inline mitigation the plan already covers, or a pointer to a new or existing ADR under
   `architecture/decisions/` (MADR format, per Principle II) if the plan is knowingly
   accepting the risk as a trade-off. A finding with neither is not done.

6. **Write the findings** to `FEATURE_DIR/well-architected-review.md` using the structure
   below. If the file already exists, append a new dated review section rather than
   overwriting — a plan can reasonably be reviewed more than once as it evolves.

**Do not** mark a finding resolved yourself. Like the other checklists in this template,
this is a reviewer-owned artifact: the tech lead or accountable engineer decides when a
risk is actually mitigated.

## What it looks like

`specs/<feature>/well-architected-review.md`:

```markdown
# AWS Well-Architected Review: [FEATURE NAME]

**Plan reviewed**: plan.md ([date/commit])
**Reviewer**: [unfilled until a human reviews this]

## Operational Excellence

- **[Medium risk]** No CloudWatch alarm defined for Batch job failures — plan §Technical
  Context doesn't mention alerting. *Mitigation: add to tasks.md, or accept via ADR.*

## Security

- **[High risk]** Plan stores raw sample metadata in S3 without a stated classification.
  *Needs: either a classification note here, or ADR if PII handling is intentionally
  deferred.*
- **[Not applicable]** No Bedrock agent in this plan — guardrails question skipped.

## Reliability
...

## Performance Efficiency
...

## Cost Optimization
...

## Sustainability
...

## Open risks carried forward

[High/Medium risk items with no mitigation or ADR yet — this section should be empty
before the plan is accepted.]
```

## Done When

- [ ] All in-scope pillars evaluated against what this plan actually proposes, not generic
      boilerplate
- [ ] Every finding classified (High / Medium / Low / Not applicable) with a one-line reason
- [ ] Every High or Medium risk finding has a mitigation or an ADR pointer — none left bare
- [ ] Findings written to `FEATURE_DIR/well-architected-review.md`
- [ ] Completion reported to user with the file path and a count of open High/Medium risks
