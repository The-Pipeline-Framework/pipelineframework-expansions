# TPF Expansions

This repository owns versioned distribution packages that group compatible TPF Blocks, Connectors, and supporting integration assets.

An Expansion is packaging and compatibility ownership. It does not create a runtime step kind, compiler semantic model, connector authority, application credentials, or runtime implementation.

Use the sole `central-publishing` Maven profile only for signing and deploying the canonical reactor. Do not introduce alternate source universes, module graphs, or build topologies.

Always use an isolated Maven repository:

    -Dmaven.repo.local="$PWD/.m2/repository"

