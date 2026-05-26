#!/usr/bin/env bash
# Render chart/ into templates/ for Gibbon's LLM engine (flat *.yaml manifests).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v helm >/dev/null 2>&1; then
  echo "helm is required: https://helm.sh/docs/intro/install/" >&2
  exit 1
fi

mkdir -p templates
helm template mini-api ./chart --namespace default > templates/rendered.yaml

# Split multi-doc YAML into one file per kind (Gibbon scans templates/*.yaml).
python3 - "$ROOT/templates/rendered.yaml" <<'PY'
import sys
from pathlib import Path

src = Path(sys.argv[1])
text = src.read_text()
docs = [d.strip() for d in text.split("\n---\n") if d.strip()]
out_dir = src.parent
for doc in docs:
    kind = None
    for line in doc.splitlines():
        if line.startswith("kind:"):
            kind = line.split(":", 1)[1].strip().lower()
            break
    if not kind:
        continue
    (out_dir / f"{kind}.yaml").write_text(doc + "\n")
src.unlink()
print(f"Wrote {len(docs)} manifest(s) to {out_dir}/")
PY
