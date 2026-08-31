workspace "AntlerBio Architecture" "C4 model of the AntlerBio platform" {

    model {
        scientist = person "Scientist / Researcher" "Runs experiments, requests analyses, reviews results"
        dataEngineer = person "Platform Engineer" "Builds and operates the platform"

        labSystems = softwareSystem "Lab Instruments & LIMS/ELN" "Source of omics and phenomics instrument data" "External"
        genomicDb = softwareSystem "External Reference Databases" "Public and licensed genomic/phenomic reference data" "External"

        antlerbio = softwareSystem "AntlerBio Platform" "Ingests, curates, and analyzes omics and phenomics data" {
            apiLayer = container "API Layer" "Serves platform APIs to internal tools and partners" "API Gateway / Lambda"
            dataLake = container "Data Lake" "Raw, curated (bronze/silver/gold) storage and governance" "S3 + Lake Formation + Glue"
            genomicsPipeline = container "Genomics/Phenomics Pipeline" "Runs bioinformatics workflows over omics and phenomics data" "Nextflow on AWS Batch"
            agenticLayer = container "Agentic Analysis Layer" "AI agents for extraction, insight generation, and Q&A over curated data" "Amazon Bedrock AgentCore (Runtime, Gateway, Memory, Identity)"
            knowledgeGraph = container "Biological Knowledge Graph" "Genes, proteins, biomarkers, indications and interventions extracted from literature, resolved against canonical IDs and cross-referenced with KEGG/Reactome pathway data" "Neo4j (GraphRAG)"
            ontology = container "Biological & Domain Ontology" "Class/schema layer (TBox): OBO Foundry ontologies (Gene Ontology, ChEBI, Mondo, Uberon), extended with AntlerBio's own domain concepts (farm, cow, experiment)" "Neo4j subgraph via neosemantics (n10s) — same instance as the Knowledge Graph"
            dsWorkbench = container "Data Science Workbench" "Model development, training, and experimentation" "Amazon SageMaker"

            !adrs decisions madr
        }

        scientist -> apiLayer "Requests analyses, views results via"
        dataEngineer -> dataLake "Operates and curates"
        labSystems -> genomicsPipeline "Sends raw instrument data to"
        genomicsPipeline -> dataLake "Writes curated results to"
        genomicsPipeline -> genomicDb "Queries reference data from"
        dataLake -> agenticLayer "Provides context to"
        dataLake -> dsWorkbench "Provides training data to"
        agenticLayer -> knowledgeGraph "Extracts entities and relationships into, queries via GraphRAG"
        genomicDb -> knowledgeGraph "Canonical pathway data (KEGG/Reactome) imported into"
        knowledgeGraph -> ontology "References classes via instance_of edges in"
        genomicDb -> ontology "OBO ontologies (Gene Ontology, ChEBI, Mondo, Uberon) imported into"
        agenticLayer -> apiLayer "Exposes insights via"
        dsWorkbench -> dataLake "Writes model outputs to"
    }

    views {
        systemContext antlerbio "SystemContext" {
            include *
            autoLayout
        }

        container antlerbio "Containers" {
            include *
            autoLayout
        }

        styles {
            element "Person" {
                shape person
                background #08427b
                color #ffffff
            }
            element "Software System" {
                background #1168bd
                color #ffffff
            }
            element "External" {
                background #999999
                color #ffffff
            }
            element "Container" {
                background #438dd5
                color #ffffff
            }
        }
    }

}
