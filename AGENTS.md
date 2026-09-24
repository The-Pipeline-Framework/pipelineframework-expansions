# Expansions Repository Instructions

This repository owns version-aligned distribution POMs that group compatible TPF Blocks, Connectors, and supporting
integration assets.

## Boundary

- An Expansion is packaging and compatibility ownership. It does not create a runtime step kind, compiler semantic
  model, Connector authority, application credentials, or runtime implementation.
- Keep distribution modules declarative. Semantic behavior belongs to the owning contract, compiler, Connector, or
  Block repository.
- Preserve application ownership of bindings, credentials, configuration, and Command authority.
- Depend on released component artifacts; do not copy their source or create a parallel build universe.

## Cross-repository changes

Update canonical documentation or an ADR in `pipelineframework` when a distribution changes the advertised
capability set or compatibility promise. Use the GitNexus `tpf` group for cross-repository impact and verify
findings in the owning worktree.

## Build and publication

Owner-local verification is the first gate. `TPF Candidate Build` and the trusted publisher create an immutable,
commit-specific Expansions candidate for the coordination repository; `tpf/system-tests` records downstream
evidence on that exact source SHA. Use a compatibility set for coordinated repository changes, and require a green
full train for formal BOM or release promotion. Keep the stable owner suite command in `.github/tpf-system-tests.json`.

Always use the repository-local Maven cache:

```sh
./mvnw <goals> -Dmaven.repo.local="$PWD/.m2/repository"
```

Do not introduce Maven profiles except `central-publishing`. It may attach, sign, and deploy artifacts but must not
select another source universe, module graph, or build topology.

Do not commit, push, publish, or change another repository unless explicitly requested.
