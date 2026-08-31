# AntlerBio Spec Kit Template

Reusable starting point for AntlerBio engineering projects: real [GitHub Spec
Kit](https://github.com/github/spec-kit) (spec-driven development), a C4 architecture
model published free via GitHub Pages, and a Jira convention — wired together and
governed by one constitution.

This is meant to be a **GitHub template repository**. AntlerBio devs click "Use this
template" to start a new project pre-loaded with all of this, rather than reassembling
it from scratch each time.

## What's in here

| Piece | Where | What it does |
|---|---|---|
| Spec Kit | `.specify/`, `.claude/skills/speckit-*` | Real spec-driven workflow: `/speckit-constitution`, `/speckit-specify`, `/speckit-plan`, `/speckit-tasks`, `/speckit-clarify`, `/speckit-analyze`, `/speckit-checklist`, `/speckit-implement`, `/speckit-converge` — installed via the actual `specify` CLI, not hand-copied |
| Constitution | `.specify/memory/constitution.md` | AntlerBio's governing principles: spec-first, reference architecture as code, quality gates, least privilege, reversible decisions. Edit this per-project if a project genuinely needs different rules — don't fork the process instead |
| C4 architecture | `architecture/workspace.dsl` | Structurizr DSL — the architecture model as text, versioned alongside the code it describes |
| Architecture publishing | `.github/workflows/publish-architecture.yml` | Free, self-hosted: validates and exports `workspace.dsl` to an interactive site on GitHub Pages on every push. No Structurizr license needed |
| Jira convention | `.specify/templates/tasks-template.md` (Jira Convention section) | `tasks.md` stays the source of truth; task IDs carry a `[JIRA-xxx]` prefix once an issue exists |
| Jira automation (optional) | `.github/workflows/jira-sync.yml.example` | Inactive by default — rename to enable, or just ask Claude to sync `tasks.md` to Jira directly once the Atlassian connector is authorized |
| ADRs | `architecture/decisions/` (MADR format) + `!adrs` in `workspace.dsl` | Decisions live next to the model they affect. **Note**: the free static export renders diagrams only, not ADRs — browse `architecture/decisions/` on GitHub directly, or use Structurizr Local to see them attached to the model |
| CI | `.github/workflows/ci.yml`, `.github/dependabot.yml` | Enforces the constitution's gate table: lint, tests + 80% coverage gate, CodeQL SAST, dependency review on PRs, weekly Dependabot scans. Written to pass cleanly on this still-empty template; starts gating for real once source + tests exist |
| PR template | `.github/PULL_REQUEST_TEMPLATE.md` | Forces a spec link, a constitution-compliance checklist, and an explicit human-reviewer acknowledgment on every PR |
| CODEOWNERS | `.github/CODEOWNERS` | Placeholder domain ownership mirroring the Architecture Constraints table — fill in real handles/teams before it does anything |
| AWS Well-Architected review | `.claude/skills/well-architected-review/` | AntlerBio-authored skill (not from upstream Spec Kit): reviews a feature's `plan.md` against the six Well-Architected pillars, writes risk-flagged findings to `well-architected-review.md`. Design-time and human-owned — not a CI gate yet |

## Setting this up as a template

1. Push this repo to GitHub under the AntlerBio org.
2. Repo Settings → General → check "Template repository."
3. Repo Settings → Pages → Source → "GitHub Actions" (for the architecture site).
4. Done — future projects start from **Use this template**, not a blank repo.

## Using it for a new project

Each new project should still run through the constitution once for itself — most of
AntlerBio's principles will carry over unchanged, but the Architecture Constraints table
(which AWS services, which pipeline framework) may need adjusting per-project. In Claude
Code, inside the new project:

```
/speckit-constitution   # confirm or amend the inherited principles
/speckit-specify        # describe the first feature
/speckit-plan           # turn the spec into an implementation plan
/speckit-tasks          # break the plan into atomic tasks
/speckit-implement      # execute
```

Update `architecture/workspace.dsl` as part of `/speckit-plan` whenever a plan makes an
architecture decision — the constitution requires it (Principle II). The published site
should never drift more than one commit behind reality.

## Why real Spec Kit instead of a hand-rolled version

This was built by actually running `specify init --integration claude` — the `speckit-*`
skill files in `.claude/skills/` are genuine, CLI-generated Spec Kit skills, not
hand-approximated copies. That matters for two reasons: they stay upgradeable via
`specify integration upgrade claude` as Spec Kit evolves, and the `.specify/templates/`
files are read live at runtime by the skills (not frozen into them), so the
customizations in this repo — the constitution, the Jira convention — take effect
automatically without needing the skills themselves to be edited.

`well-architected-review` sits alongside them but isn't one of them — it's an
AntlerBio-authored skill, the same "institutional knowledge as a versioned skill" pattern
as the constitution itself, just scoped to one policy (AWS Well-Architected) instead of
all of engineering. `specify integration upgrade` won't touch it, and it won't be
overwritten by a future upstream Spec Kit update.

## Verifying the scaffold

```bash
specify check                 # confirms the CLI + integration state
grep -r "__SPECKIT_COMMAND" .claude/   # should return nothing — placeholders resolved
```
