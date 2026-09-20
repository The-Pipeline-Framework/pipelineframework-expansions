# The Pipeline Framework Expansions

This repository publishes versioned distributions of compatible TPF Blocks, Connectors, and integration assets.
An Expansion is ordinary Maven packaging: it does not introduce a runtime step kind, a compiler manifest, or a
second semantic model.

Published distributions:

- `org.pipelineframework.expansions:graphql` — GraphQL contract/provider plus the GraphQL and GraphQL Agent Blocks.
- `org.pipelineframework.expansions:openapi` — pinned HTTP connector/provider plus the OpenAPI representation-mapper Block.

Applications retain connector bindings, credentials, configuration, and Command authority. Adding an Expansion never
grants an external capability.

## Use an Expansion

```xml
<dependency>
    <groupId>org.pipelineframework.expansions</groupId>
    <artifactId>graphql</artifactId>
    <version>26.9.4-SNAPSHOT</version>
    <type>pom</type>
</dependency>
```

The OpenAPI acquisition plugin is build tooling and cannot be activated transitively by a dependency. Applications
using OpenAPI acquisition must also configure `org.pipelineframework:connector-openapi-maven-plugin` explicitly at
the same `pipelineframework.connectors.version` used by this release.

Build with an isolated Maven repository:

```sh
./mvnw clean verify -U -Dmaven.repo.local="$PWD/.m2/repository"
```
