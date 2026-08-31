---
status: "accepted"
date: 2026-08-23
decision-makers: Mark Brundrett
---

# Use C4 (Structurizr DSL) for software architecture, published as a free self-hosted static site

## Context and Problem Statement

AntlerBio needs a durable way to model and share software architecture that AI agents
can also read during design (per the constitution's Principle II). Structurizr's cloud
service reaches end-of-life on 30 September 2026, so "just use Structurizr Cloud" is no
longer an option, and the successor self-hosted "server" product carries a per-user
license. What should the architecture-modeling approach and hosting be, for a company
this size, at zero incremental cost?

## Decision Drivers

* Must be free — no per-seat SaaS cost for a small team
* Must be git-versioned, diffable, and readable by AI agents (text, not a binary diagram)
* Must not require standing up and maintaining a server
* Enterprise/solution architecture (ArchiMate) is handled separately — this decision is
  scoped to software architecture only

## Considered Options

* Structurizr DSL, exported to a static site and hosted on GitHub Pages (free)
* Structurizr self-hosted "server" product (paid, licensed per unique user/year)
* IcePanel (cloud SaaS, C4-native, free tier capped at 5 editors / 100 objects)
* ArchiMate for software architecture too (single tool for all layers)

## Decision Outcome

Chosen option: "Structurizr DSL, exported to a static site on GitHub Pages", because
it's the only option that is simultaneously free, git-native, and produces a format
(plain-text DSL) that an LLM agent can read directly during design — the paid server
and IcePanel both solve real problems (live multi-user editing, SSO) that this team
doesn't need yet at this size.

### Consequences

* Good, because zero licensing cost, and the model lives in the same repo/PR flow as
  the code it describes
* Good, because the DSL is exactly what `/speckit-plan` can read and update when a plan
  makes an architecture decision
* Bad, because no live in-browser multi-user editing or commenting — editing happens
  through the DSL/git flow, which is fine for a tech-lead-owned architecture repo but
  would need revisiting if non-technical stakeholders need to edit directly
* Bad, because the free static export does not render ADRs or documentation pages
  (only diagrams) — ADRs are wired in via `!adrs` for the DSL model and Structurizr
  Local, but on the published GitHub Pages site, browse `architecture/decisions/`
  directly on GitHub instead

## Pros and Cons of the Options

### Structurizr server (paid)

* Good, because SSO, RBAC, live editing, comments
* Bad, because recurring license cost the team doesn't need yet at this size

### IcePanel

* Good, because best-in-class visual/collaborative editing, SOC2/GDPR compliant
* Bad, because free tier caps out fast (100 objects), and it's not diagrams-as-code —
  loses the git-diff and agent-readability properties

### ArchiMate for everything

* Bad, because it's the wrong altitude for component/container-level software
  architecture — forcing it down to that level of detail is the same mistake as forcing
  C4 up to business-capability level. Keep the two notations at their respective layers.
