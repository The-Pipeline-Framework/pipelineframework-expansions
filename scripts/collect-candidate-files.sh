#!/usr/bin/env bash
set -euo pipefail

output_dir=${1:?usage: collect-candidate-files.sh OUTPUT_DIR}
candidate_manifest=${CANDIDATE_MANIFEST:?CANDIDATE_MANIFEST must point to the prepared candidate version manifest}
[[ ! -e "$output_dir" ]] || { echo "output directory already exists: $output_dir" >&2; exit 2; }
repo_root=$(cd "$(dirname "$0")/.." && pwd)
[[ -f "$candidate_manifest" && ! -L "$candidate_manifest" ]] || { echo "missing prepared candidate manifest: $candidate_manifest" >&2; exit 1; }
mkdir -p "$output_dir/repository"
cp "$candidate_manifest" "$output_dir/candidate-manifest.json"
version=$(python3 - "$candidate_manifest" <<'PY'
import sys
import json
print(json.loads(open(sys.argv[1]).read())["candidateVersion"])
PY
)
local_repository="$repo_root/.m2/repository"
coordinates=(
  "org.pipelineframework:pipeline-expansions"
  "org.pipelineframework.expansions:graphql"
  "org.pipelineframework.expansions:openapi"
)
for coordinate in "${coordinates[@]}"; do
  IFS=: read -r group_id artifact_id <<< "$coordinate"
  group_path=$(printf '%s' "$group_id" | tr '.' '/')
  artifact_dir="$local_repository/$group_path/$artifact_id/$version"
  destination="$output_dir/repository/$group_path/$artifact_id/$version"
  [[ -f "$artifact_dir/$artifact_id-$version.pom" ]] || {
    echo "missing built candidate POM: $artifact_dir/$artifact_id-$version.pom" >&2
    exit 1
  }
  mkdir -p "$destination"
  cp "$artifact_dir/$artifact_id-$version.pom" "$destination/"
done
