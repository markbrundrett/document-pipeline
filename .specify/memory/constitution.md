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

- Version: 1.4.0 → 2.0.0 (MAJOR — document rescoped from org-wide to project-scoped,
  architecture constraints removed)
- Retitled: "AntlerBio Engineering Constitution" → "AntlerBio Document Pipeline
  Constitution". This file now governs the document-pipeline project only; the org-wide
  constitution continues to live in the AntlerBio Spec Kit template repository. Added a
  Scope paragraph naming the inherited baseline (v1.4.0) and the project adoption date
- Principles: all five carried over unchanged in wording and intent (no renames)
- Removed sections: five Architecture Constraints rows not used by this project —
  Bioinformatics Pipelines (Nextflow on AWS Batch), Data Science (SageMaker),
  Domain / Master Data Model (TBD), Semantic Layer (TBD), Analytics Agents (TBD). These
  remain in force platform-wide; they are simply out of scope here. This removal is what
  makes the bump MAJOR rather than MINOR
- Added: Entity Resolution row (TBD) — promotes the follow-up TODO carried since v1.2.0
  into an explicit, blocking architecture gap, since this is the project where literature
  mentions must be mapped to canonical identifiers. Carries one hard rule that applies
  before the ADR lands: unresolved free-text mentions MUST NOT be written to the graph as
  canonical entities
- Retained: Data Lake, Query Engine, Agentic Layer, Knowledge Graph, Ontology,
  Architecture Model, Ticketing, Org Model — each narrowed in its Notes to what this
  project actually does with it
- Governance: added the upstream-sync rule — amendments touching an inherited principle
  must be raised against the template repository, not diverged silently here
- Follow-up TODOs: resolve Entity Resolution via ADR during /speckit-plan for the first
  extraction feature; it must not be left open past plan acceptance
-->

# AntlerBio Document Pipeline Constitution

**Scope**: This constitution governs the `document-pipeline` project — ingesting scientific
literature and related documents, extracting biological entities and relationships from
them, and loading those into the AntlerBio biological knowledge graph against the OBO
ontology layer. It is derived from the AntlerBio Engineering Constitution v1.4.0 and adopted
by this project on 2026-09-01. The five Core Principles below are inherited verbatim and are
not project-local; the Architecture Constraints table is narrowed to the layers this project
actually builds on.

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

Narrowed to the layers `document-pipeline` builds on. Platform-wide layers this project
does not use — bioinformatics pipelines, the data science workbench, the semantic layer,
analytics agents, and the domain/master data model — remain governed by the org-wide
AntlerBio Engineering Constitution and are out of scope here. A plan that needs one of
them MUST cite that document and record an ADR, rather than reintroducing the row locally.

| Layer | Technology | Notes |
|---|---|---|
| Data Lake | Amazon S3 + AWS Lake Formation + Glue Data Catalog + Apache Iceberg table format | Landing and curation zone for source documents and extraction outputs. Governed permissions and tags at the Lake Formation layer, not ad hoc bucket policies. Iceberg via Glue's native Iceberg REST Catalog API — no separate catalog service by default. Source documents land in an unclassified staging/quarantine zone first: nothing reaches governed bronze until its licensing and redistribution terms are classified alongside the usual validation |
| Query Engine | Amazon Athena | Standard SQL over Iceberg tables via the Glue Catalog — the tabular counterpart to Cypher over the graph. Extraction provenance, run metadata, and per-document processing state are queryable here |
| Agentic Layer | Amazon Bedrock AgentCore (Runtime, Gateway, Memory, Identity) + Guardrails, Knowledge Bases | The extraction engine for this project. Guardrails required on every agent handling PII or external input — every ingested document counts as external input. Gateway is the only sanctioned path from an agent to a tool or external system. Bedrock Knowledge Bases remain the vector-search layer for source-passage retrieval, not entity relationships |
| Knowledge Graph | Neo4j (GraphRAG) — see `architecture/decisions/0002-neo4j-graphrag-for-biological-knowledge-graph.md` | Destination for extracted entities (genes, proteins, pathways, biomarkers, indications, interventions) and their relationships, plus multi-hop query. Every extracted assertion carries provenance back to its source document and passage — Principle IV is enforced structurally in the graph, not left to the agent's prose |
| Ontology | Neo4j subgraph, seeded via neosemantics (n10s) from OBO Foundry ontologies (Gene Ontology, ChEBI, Mondo, Uberon) | Class/schema layer (TBox) — distinct from the Knowledge Graph's instance data (ABox). Extracted entities reference ontology classes via `instance_of` edges rather than this project inventing its own taxonomy. Same Neo4j instance as the Knowledge Graph, not a separate system |
| Entity Resolution | **TBD** — blocking, must be settled by first plan acceptance | Mapping literature mentions to canonical identifiers (HGNC, UniProt, ChEBI, Mondo) before an entity is written to the graph. Carried as an open gap since constitution v1.2.0; this is the project where it surfaces, so it MUST be decided via ADR during `/speckit-plan` for the first extraction feature rather than deferred again. One rule applies ahead of that ADR: unresolved free-text mentions MUST NOT be written into the graph as though they were canonical entities — they are either resolved, or quarantined for review |
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

This constitution supersedes ad hoc process decisions within `document-pipeline`. Amendments
require a documented rationale, review by the accountable tech leads, and a version bump
following semantic versioning: MAJOR for incompatible governance or principle removals,
MINOR for a new principle or materially expanded guidance, PATCH for wording/clarification
only. All specs, plans, and PR reviews are expected to verify compliance with this document;
complexity that violates a principle must be explicitly justified in the plan's Risks
section, not silently introduced.

Because the five Core Principles are inherited rather than project-local, an amendment that
changes a principle's meaning MUST be raised against the AntlerBio Spec Kit template
repository and adopted here from that change — this project does not fork the principles
silently. Project-local amendments are confined to the Scope paragraph, the Architecture
Constraints table, and project-specific gates.

**Version**: 2.0.0 | **Ratified**: 2026-08-23 | **Last Amended**: 2026-09-01
