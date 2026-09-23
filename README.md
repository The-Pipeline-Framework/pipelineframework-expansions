# The Pipeline Framework Expansions

This repository publishes version-aligned distributions of compatible TPF Blocks, Connectors, and supporting
integration assets. An Expansion is ordinary Maven packaging: it does not introduce a runtime step kind, a compiler
manifest, or a second semantic model.

Published distributions:

- `org.pipelineframework.expansions:graphql` — GraphQL contract/provider plus GraphQL and GraphQL Agent Blocks;
- `org.pipelineframework.expansions:openapi` — pinned HTTP Connector/provider plus the OpenAPI representation-mapper
  Block.

Applications retain Connector bindings, credentials, configuration, and Command authority. Adding an Expansion
never grants an external capability.

```xml
<dependency>
    <groupId>org.pipelineframework.expansions</groupId>
    <artifactId>graphql</artifactId>
    <version>26.9.4-SNAPSHOT</version>
    <type>pom</type>
</dependency>
```

The OpenAPI acquisition plugin is build tooling and cannot be activated transitively by a dependency. Configure
`org.pipelineframework:connector-openapi-maven-plugin` explicitly at the matching Connector version.

Build with an isolated Maven repository:

```sh
./mvnw clean verify -U -Dmaven.repo.local="$PWD/.m2/repository"
```

Use the `central-publishing` profile only to sign and deploy the canonical reactor. See
[Use an Expansion](https://pipelineframework.org/develop/expansions/) and
[TPF Components and Repositories](https://pipelineframework.org/architecture/components-and-repositories).

## System-test candidates

`TPF Candidate Build` runs at the exact pull-request or `main` SHA with read-only permissions and no secrets. It
builds a commit-specific Expansions candidate and uploads only allowlisted Maven files and preliminary metadata. The
trusted `TPF Candidate Publish` workflow validates the build and current head, publishes those files to this
repository's GitHub Packages registry, then dispatches `tpf-candidate-v1` to the coordination repository without
executing project or fork code.

Fork pull requests require `safe-to-system-test`. Candidate publication uses the coordination GitHub App and the
workflow package token; it uses no Maven Central credentials or GPG key.
