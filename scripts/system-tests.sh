#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  candidate-version)
    mode=${2:?usage: system-tests.sh candidate-version pull_request|push PR_NUMBER SHA}
    pr_number=${3:--}
    sha=${4:?}
    case "$mode" in
      pull_request) mode=pr ;;
      push) mode=main ;;
      *) echo "event must be pull_request or push" >&2; exit 2 ;;
    esac
    current_version=$(python3 - <<'PY'
import xml.etree.ElementTree as ET
root = ET.parse("pom.xml").getroot()
print(root.findtext("{http://maven.apache.org/POM/4.0.0}version", ""))
PY
)
    if [[ "$current_version" == *-SNAPSHOT ]]; then
      base_version=${current_version%-SNAPSHOT}
    else
      base_version=${current_version%%-pr.*}
      base_version=${base_version%%-main.*}
    fi
    actual=$(bash scripts/candidate-version.sh "$mode" "$base_version" "$pr_number" "$sha")
    if [[ "$mode" == pr ]]; then
      expected="${base_version}-pr.${pr_number}.${sha:0:12}"
    elif [[ "$mode" == main ]]; then
      expected="${base_version}-main.${sha:0:12}"
    else
      exit 2
    fi
    [[ "$actual" == "$expected" ]] || exit 1
    ;;
  reactor-coordinates)
    python3 - <<'PY'
import pathlib
import xml.etree.ElementTree as ET

ns = {"m": "http://maven.apache.org/POM/4.0.0"}
root_pom = pathlib.Path("pom.xml")
expected = ET.parse(root_pom).getroot().findtext("m:version", namespaces=ns)
assert expected and ("-pr." in expected or "-main." in expected)
for pom in [root_pom, *sorted(pathlib.Path(".").glob("*/pom.xml"))]:
    root = ET.parse(pom).getroot()
    parent = root.find("m:parent", ns)
    if parent is not None:
        assert parent.findtext("m:version", namespaces=ns) == expected, pom
    if root.findtext("m:artifactId", namespaces=ns) == "pipeline-expansions":
        assert root.findtext("m:version", namespaces=ns) == expected
    assert root.findtext("m:artifactId", namespaces=ns) in {
        "pipeline-expansions", "graphql", "openapi"
    }, pom
PY
    ;;
  reactor-dependencies)
    python3 - <<'PY'
import pathlib
import subprocess
import tempfile
import xml.etree.ElementTree as ET

candidate = "3.2.1-pr.42.0123456789ab"
with tempfile.TemporaryDirectory(prefix="tpf-reactor-dependency-test-") as temporary:
    root = pathlib.Path(temporary)
    (root / "pom.xml").write_text("""<project><groupId>org.pipelineframework</groupId><artifactId>pipeline-expansions</artifactId><version>3.2.1-SNAPSHOT</version><properties><pipelineframework.blocks.version>8.0.0-pr.4.abcdef123456</pipelineframework.blocks.version><pipelineframework.connectors.version>9.0.0-pr.5.abcdef123456</pipelineframework.connectors.version><pipelineframework.contracts.version>7.0.0-pr.6.abcdef123456</pipelineframework.contracts.version></properties></project>""")
    (root / "consumer").mkdir()
    (root / "internal").mkdir()
    (root / "consumer/pom.xml").write_text("""<project><groupId>org.pipelineframework.expansions</groupId><artifactId>consumer</artifactId><parent><groupId>org.pipelineframework</groupId><artifactId>pipeline-expansions</artifactId><version>3.2.1-SNAPSHOT</version></parent><dependencies><dependency><groupId>org.pipelineframework.expansions</groupId><artifactId>internal</artifactId><version>3.2.1-SNAPSHOT</version></dependency><dependency><groupId>org.pipelineframework.blocks</groupId><artifactId>graphql</artifactId><version>${pipelineframework.blocks.version}</version></dependency><dependency><groupId>org.pipelineframework</groupId><artifactId>http-connector</artifactId><version>${pipelineframework.connectors.version}</version></dependency><dependency><groupId>org.pipelineframework</groupId><artifactId>pipelineframework-runtime-core</artifactId><version>${pipelineframework.contracts.version}</version></dependency></dependencies></project>""")
    (root / "internal/pom.xml").write_text("""<project><groupId>org.pipelineframework.expansions</groupId><artifactId>internal</artifactId><parent><groupId>org.pipelineframework</groupId><artifactId>pipeline-expansions</artifactId><version>3.2.1-SNAPSHOT</version></parent></project>""")
    subprocess.run(["python3", str(pathlib.Path("scripts/rewrite-reactor-dependencies.py").resolve()), str(root), candidate], check=True)
    pom = ET.parse(root / "consumer/pom.xml").getroot()
    dependencies = pom.find("dependencies")
    assert dependencies[0].findtext("version") == candidate, ET.tostring(dependencies[0], encoding="unicode")
    assert dependencies[1].findtext("version") == "${pipelineframework.blocks.version}", ET.tostring(dependencies[1], encoding="unicode")
    assert dependencies[2].findtext("version") == "${pipelineframework.connectors.version}", ET.tostring(dependencies[2], encoding="unicode")
    assert dependencies[3].findtext("version") == "${pipelineframework.contracts.version}", ET.tostring(dependencies[3], encoding="unicode")
    root_properties = ET.parse(root / "pom.xml").getroot().find("properties")
    assert root_properties.findtext("pipelineframework.blocks.version") == "8.0.0-pr.4.abcdef123456"
    assert root_properties.findtext("pipelineframework.connectors.version") == "9.0.0-pr.5.abcdef123456"
    assert root_properties.findtext("pipelineframework.contracts.version") == "7.0.0-pr.6.abcdef123456"
PY
    ;;
  resolution)
    read -r -a maven_args <<< "${MAVEN_ARGS:-}"
    unset MAVEN_ARGS
    ./mvnw -B -Dmaven.deploy.skip=true -Dgpg.skip=true -Dtpf.flatten.skip=true "${maven_args[@]}" verify
    ;;
  *) echo "usage: system-tests.sh candidate-version pr|main PR_NUMBER SHA | reactor-coordinates | reactor-dependencies | resolution" >&2; exit 2 ;;
esac
