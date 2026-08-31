<!--
Sync Impact Report
- Version: (none) → 1.0.0 (initial ratification)
- Principles defined: 5 (Spec-First, Reference Architecture as Code, Quality as a Gate,
  Least Privilege / Evidence-Grounded, Reversible Decisions & Cost Discipline)
- Added sections: Architecture Constraints, Development Workflow & Quality Gates
- Removed sections: none (initial version)
- Follow-up TODOs: none

- Version: 1.0.0 → 1.0.1 (PATCH — clarification, no principle redefined)
- Principle II: pinned the ADR location (architecture/decisions/, MADR format) now that
  CI, the PR template, CODEOWNERS, and the ADR-in-C4 wiring exist to enforce it
- Follow-up TODOs: none

- Version: 1.0.1 → 1.1.0 (MINOR — new gate added, materially expanded guidance)
- Principle III: split the Well-Architected check out from "runs automatically at every
  commit," which was aspirational and untrue of it — coverage/SAST/dependency checks are
  genuinely CI-enforced, the Well-Architected review is not. It now names the actual
  mechanism: the well-architected-review skill, run at plan time, human-owned
- Added: AWS Well-Architected review row to the Development Workflow & Quality Gates table
- Follow-up TODOs: a CI-enforced tier (static IaC scanning) once infrastructure code
  exists to scan — not yet built

- Version: 1.1.0 → 1.2.0 (MINOR — new architecture layer, materially expanded guidance)
- Architecture Constraints: Agentic Layer now names Bedrock AgentCore specifically
  (Runtime, Gateway, Memory, Identity) instead of the generic "Bedrock (agents,
  guardrails, knowledge bases)" — that's what's actually being built on
- Added: Knowledge Graph row (Neo4j, GraphRAG) — an explicit, accepted deviation from
  the AWS-native default, justified in ADR-0002. workspace.dsl updated to add the
  knowledgeGraph container and its relationships
- Follow-up TODOs: entity-resolution approach (mapping literature mentions to canonical
  gene/protein IDs) still needs its own design — belongs in the feature's plan.md, not
  here

- Version: 1.2.0 → 1.3.0 (MINOR — foundational data-platform defaults settled, three
  known gaps made explicit)
- Architecture Constraints: settled Apache Iceberg as the default table format, Glue's
  native Iceberg REST Catalog as the default catalog (Apache Polaris deferred to a future
  ADR if a real multi-engine/multi-cloud need arises), Spot as the default for Nextflow on
  Batch, Amazon Athena named as the default query engine, and an explicit staging/
  quarantine requirement for external system data ahead of governed bronze
- Added: three TBD placeholder rows — Domain/Master Data Model, Semantic Layer, Analytics
  Agents — marking known, deliberately undecided architecture gaps rather than leaving
  them silently absent. Each names what decides it and when
- Follow-up TODOs: resolve the three TBD rows via ADR as real projects surface the need;
  none should be decided speculatively ahead of that

- Version: 1.3.0 → 1.4.0 (MINOR — new architecture layer, sharpened two TBD notes)
- Architecture Constraints: added an Ontology row — OBO Foundry ontologies (Gene Ontology,
  ChEBI, Mondo, Uberon) imported into Neo4j via neosemantics (n10s) as a distinct
  class/schema subgraph (TBox), separate from the Knowledge Graph's instance data (ABox)
- Domain / Master Data Model TBD: sharpened to lean toward convergence with the graph for
  the conceptual/classification layer, as a local extension of the Ontology row —
  operational/transactional data still defaults to Iceberg tables. Still TBD: full design
  needs an ADR when a project first needs it
- Semantic Layer TBD: noted Apache Ossie (incubating, entered the Apache Incubator July
  2026) as the emerging interchange format for portable business-metric definitions across
  dbt/BI/agents — too new to adopt as infrastructure, but the eventual semantic-layer-engine
  choice should weight toward Ossie export support to avoid metric-definition drift
- workspace.dsl updated to add the ontology container and its relationships
- Follow-up TODOs: resolve Domain/Master Data Model and Semantic Layer via ADR as real
  projects surface the need, as before
-->

# AntlerBio Engineering Constitution

## Core Principles

### I. Spec-First, Human-Validated
Every feature starts as a spec (`spec.md`) before any code is written. AI generates from
the spec and the task list, not from an engineer's head in the moment. Verification —
does the code conform to the spec, do tests pass, are security gates clear — is where AI
excels and runs automatically. Validation — is this the right system, are requirements
complete, does this align with what AntlerBio actually needs — is a human judgment call
that cannot be delegated. Spec sign-off by the accountable product owner or tech lead is
the highest-stakes gate in the pipeline: a wrong requirement, automated at pace, scales
the mistake across every line of code that follows.

### II. Reference Architecture Is Documented as Code
Every system's architecture is modeled in C4 (Structurizr DSL) and published from the
architecture repository — never left as a diagram in someone's head or a stale slide.
Significant design decisions are recorded as ADRs under `architecture/decisions/`
(MADR format, template at `architecture/decisions/0000-adr-template.md`) and linked from
the plan they belong to. Deviating from a reference pattern requires a written ADR, not
a verbal agreement.
AWS is the reference platform (see Architecture Constraints below); new components
default to the established patterns unless an ADR justifies otherwise.

### III. Quality Is a Gate, Not a Prayer
BDD/TDD discipline, coverage thresholds, and security scanning (SAST + dependency checks)
run automatically at every commit. A failed gate blocks merge with no informal exceptions.
Tests exist before the feature is coded where practical; red-green-refactor is the default
loop, AI-accelerated but human-owned.
Design also gets an AWS Well-Architected review before a plan is accepted — a human-owned,
plan-time check (the `well-architected-review` skill), not yet a CI gate. Every High or
Medium risk finding needs a mitigation or an ADR; an open risk with neither blocks
acceptance the same way a failed CI check blocks merge.

### IV. Least Privilege, Evidence-Grounded, Auditable
Functional roles carry the minimum grants needed to do the job — no broad access by
default. Agents must cite source data for factual claims; no hallucinated results ship
to a user or a stakeholder. Every material decision — an architecture choice, a spec
sign-off, a production deployment — is traceable to a committed artifact (ADR, spec,
pull request), not a conversation that leaves no trace.

### V. Reversible Decisions First, Cost Is a Design Constraint
Prefer reversible choices — feature flags, additive schema changes, views before
tables — over irreversible ones, and prefer simplicity over cleverness (YAGNI: don't
build for hypothetical futures). Model tiering (cheap models for mechanical work,
frontier models for architecture and judgment calls) and prompt caching are required
practice, not optimizations to get to later. Token and infrastructure spend are reviewed
with the same rigor as any other engineering cost line.

## Architecture Constraints

| Layer | Technology | Notes |
|---|---|---|
| Data Lake | Amazon S3 + AWS Lake Formation + Glue Data Catalog + Apache Iceberg table format | Governed permissions and tags at the Lake Formation layer, not ad hoc bucket policies. Iceberg via Glue's native Iceberg REST Catalog API — no separate catalog service by default (see Knowledge Graph row for the one accepted exception; a future multi-engine/multi-cloud need would justify Apache Polaris, decided via ADR, not assumed). External system data lands in an unclassified staging zone first — nothing reaches governed bronze until it's classified and validated |
| Bioinformatics Pipelines | Nextflow on AWS Batch, Spot by default | nf-core pipelines preferred over bespoke workflows where one exists. Spot is the default, not an optimization to revisit later — Nextflow's native retry/error-strategy handles reclamation, so on-demand needs its own justification, not the other way round |
| Query Engine | Amazon Athena | Standard SQL over Iceberg tables via the Glue Catalog — the default consumption path for scientists and the DS workbench alike |
| Agentic Layer | Amazon Bedrock AgentCore (Runtime, Gateway, Memory, Identity) + Guardrails, Knowledge Bases | Guardrails required on every agent handling PII or external input; Gateway is the only sanctioned path from an agent to a tool or external system |
| Knowledge Graph | Neo4j (GraphRAG) — deviation from AWS-native, see `architecture/decisions/0002-neo4j-graphrag-for-biological-knowledge-graph.md` | For structured biological entities (genes, proteins, pathways, biomarkers, interventions) and multi-hop queries; Bedrock Knowledge Bases remain the vector-search layer for source-passage retrieval, not entity relationships |
| Ontology | Neo4j subgraph, seeded via neosemantics (n10s) from OBO Foundry ontologies (Gene Ontology, ChEBI, Mondo, Uberon) | Class/schema layer (TBox) — distinct from the Knowledge Graph's instance data (ABox). Extracted entities reference ontology classes via `instance_of` edges rather than each project inventing its own taxonomy. Same Neo4j instance as the Knowledge Graph, not a separate system |
| Domain / Master Data Model | **TBD**, leaning toward convergence with the graph | AntlerBio's own entity relationships (e.g. farm → cow → experiment, cow → phenotype). For the conceptual/classification layer, leans toward a local extension of the Ontology row rather than a separate taxonomy; operational/transactional data (raw readings, batch logs) still defaults to Iceberg tables. Decide the full split via ADR when a project first needs to model it |
| Semantic Layer | **TBD** | A governed, single-definition layer for business metrics (e.g. "differential expression," "responder") above raw Iceberg tables. Not yet decided between a dbt-style semantic layer, Cube, or a graph-native approach. Watch Apache Ossie (incubating since July 2026) as the emerging cross-tool interchange format for these definitions — weight the eventual engine choice toward Ossie support rather than adopting Ossie itself yet, since it has no production engine behind it today. Needed before two projects quietly define the same metric two different ways — decide via ADR before that happens, not after |
| Analytics Agents | **TBD** | Natural-language query agents over the lake and/or knowledge graph, for scientists who don't write SQL or Cypher — distinct from the Agentic Layer's extraction role. Likely AgentCore-hosted, querying via Athena and/or the Knowledge Graph, but undesigned. Decide via ADR once a project actually needs scientist-facing NL query |
| Data Science | Amazon SageMaker | Model development, training, and experimentation |
| Architecture Model | C4 via Structurizr DSL, published as a static site (GitHub Pages) | Free/open-source `export` command only — no paid Structurizr license required |
| Ticketing | Jira | `tasks.md` task IDs reference Jira issue keys; Jira is the execution-tracking mirror, `tasks.md` remains the spec-of-record |
| Org Model | Team Topologies | Stream-aligned teams own their systems end-to-end; platform team owns shared reference architecture and tooling |

## Development Workflow & Quality Gates

The lifecycle is: **Constitution → Specify → Clarify → Plan → Tasks → Implement**, with
lessons learned from Implement feeding back into Clarify for the next iteration. No
phase may be skipped.

| Gate | Criterion | Enforced At |
|---|---|---|
| Spec sign-off | Product owner or accountable tech lead approves `spec.md` | Before `/speckit-plan` |
| Architecture conformance | Design matches C4 model and cites an ADR for any deviation | Plan review |
| AWS Well-Architected review | Every High/Medium risk finding has a mitigation or an ADR | Plan review (`well-architected-review` skill) |
| Coverage | Test coverage ≥ 80% on new/changed code | Every commit, CI-enforced |
| Security | SAST + dependency scan clean; no known CVEs ship | Every commit, CI-enforced |
| PR approval | AI pre-screen + human engineer review; engineer owns and merges | Before merge |
| Deployment | Human approval; policy-as-code gate; monitoring active before traffic | Before production release |

Human gates — spec sign-off, PR approval, and deployment approval — are never automated
away, regardless of how capable the tooling becomes.

## Governance

This constitution supersedes ad hoc process decisions. Amendments require a documented
rationale, review by the accountable tech leads, and a version bump following semantic
versioning: MAJOR for incompatible governance or principle removals, MINOR for a new
principle or materially expanded guidance, PATCH for wording/clarification only. All
specs, plans, and PR reviews are expected to verify compliance with this document;
complexity that violates a principle must be explicitly justified in the plan's Risks
section, not silently introduced.

**Version**: 1.4.0 | **Ratified**: 2026-08-23 | **Last Amended**: 2026-08-31
