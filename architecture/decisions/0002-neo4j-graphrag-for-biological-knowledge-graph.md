---
status: "accepted"
date: 2026-08-30
decision-makers: Mark Brundrett
---

# Use Neo4j (GraphRAG) for the biological knowledge graph, on AWS Bedrock AgentCore

## Context and Problem Statement

The document-processing pilot extracts genes, proteins, biomarkers, indications, and
interventions (drugs, nutrients, lifestyle) from papers and presentations, for downstream
differential expression, mutation, and other omics analysis. That data is interrogated
alongside KEGG/Reactome-style pathway maps, which are themselves graphs — genes and
proteins as nodes, reactions and regulatory relationships as typed edges. The dominant
query pattern is multi-hop and relational ("what's downstream of this gene in this
pathway," "which interventions target biomarkers linked to this indication"), not
semantic-similarity lookup over document text. What storage and retrieval architecture
should the extraction pipeline write into?

## Decision Drivers

* The domain is graph-shaped by construction (KEGG/Reactome model biology as graphs);
  forcing it into flat documents or rows loses the relationships that make it useful
* Downstream analysis needs multi-hop traversal and aggregation, which vector similarity
  search does not do well
* Extracted literature relationships need to merge with canonical pathway data via
  resolved entity IDs (HGNC/UniProt), not sit as disconnected mentions
* Evidence and provenance (which paper supports which edge) must stay traceable, per the
  constitution's Principle IV
* AWS is the reference platform (Principle II); a deviation needs to earn its place, not
  just be the maintainer's preference

## Considered Options

* Neo4j (AuraDB or self-hosted) with the GraphRAG/LangChain ecosystem, agents hosted on
  Amazon Bedrock AgentCore
* Amazon Neptune (property graph, openCypher/Gremlin) with Neptune Analytics vector search
  — stays fully AWS-native, no ADR-worthy deviation
* Flat vector RAG only (Bedrock Knowledge Bases + OpenSearch Serverless), as originally
  sketched in the first pipeline diagram — no graph store at all

## Decision Outcome

Chosen option: "Neo4j with the GraphRAG/LangChain ecosystem, agents on Bedrock AgentCore,"
because the GraphRAG tooling and LangChain integration depth around Neo4j specifically are
materially more mature than Neptune's equivalent today, and this pipeline's entire value
proposition rests on graph traversal quality — that is not a place to accept a less mature
ecosystem for the sake of staying AWS-native. This is an explicit, accepted deviation from
the AWS-only default in Principle II.

Bedrock AgentCore (Runtime, Gateway, Memory, Identity) hosts the extraction and retrieval
agents regardless of graph store choice, so the deviation is scoped to the data layer, not
the agent runtime — Gateway is the sanctioned path from the agent to the Neo4j tool and to
any KEGG/Reactome lookup, keeping least-privilege scoping (Principle IV) intact.

### Consequences

* Good, because query patterns that actually matter (multi-hop, pathway traversal,
  aggregation across papers) are natively supported rather than approximated
* Good, because extracted relationships can be merged directly with canonical KEGG/Reactome
  data once entities are resolved to canonical IDs, giving one queryable graph instead of
  two disconnected sources
* Good, because a graph query result shows its own path of relationships, which is a
  stronger evidence trail than a list of semantically-similar chunks
* Bad, because it adds a second data store outside the AWS-native default, with its own
  operational surface (backup, scaling, access control) separate from Lake Formation
* Bad, because entity resolution (mapping literature mentions to canonical gene/protein
  IDs) is new, non-trivial engineering that a flat pipeline would not have needed
* Bad, because the agentic extraction schema changes from flat per-document JSON to typed
  triples, which touches the merge/validation stages already designed in the pipeline

## Pros and Cons of the Options

### Amazon Neptune

* Good, because it stays fully AWS-native — no deviation, no ADR needed
* Good, because Neptune Analytics now supports vector search alongside graph queries in
  one service
* Bad, because the GraphRAG/LangChain tooling ecosystem around Neptune is thinner than
  around Neo4j today — more custom integration work for the same outcome

### Flat vector RAG only

* Good, because it reuses the pipeline exactly as first designed — no new data store
* Bad, because it cannot do multi-hop pathway reasoning, which is the actual point of
  interrogating KEGG/Reactome-style data — this option does not solve the stated problem
