# Gibbon examples: Helm chart + OpenAI

A minimal real-world-style Helm chart (`chart/`) and Gibbon config that edits **rendered** Kubernetes manifests in `templates/`.

## Layout

| Path | Purpose |
|------|---------|
| `chart/` | Helm chart (Deployment, Service, ConfigMap) |
| `templates/` | Flat manifests for Gibbon (`helm template` output, split by kind) |
| `gibbon.yaml` | OpenAI LLM engine config (no secrets in this file) |
| `scripts/render-chart.sh` | Regenerate `templates/` after changing the chart |

## Prerequisites

- [Gibbon](https://github.com/your-org/gibbon) installed (`uv tool install` or `uv run` from the Gibbon repo)
- [Helm 3](https://helm.sh/docs/intro/install/)
- OpenAI API credits and an API key from [platform.openai.com](https://platform.openai.com)
- A **git repository** (Gibbon uses GitOps: branch, commit per instruction, push)

## API key (recommended: environment, not YAML)

**Do not** put `api_key` in `gibbon.yaml` if the repo might be shared or committed.

Gibbon resolves credentials in this order:

1. `OPENAI_API_KEY` environment variable
2. `GIBBON_LLM_API_KEY` environment variable
3. `api_key` in `gibbon.yaml` (last resort; easy to leak)

### Option A: `.env` file (local dev)

```bash
cp .env.example .env
# Edit .env and set OPENAI_API_KEY=sk-...
set -a && source .env && set +a
```

`.env` is listed in `.gitignore`.

### Option B: Shell export (one-off)

```bash
export OPENAI_API_KEY='sk-...'
```

### Option C: Secret manager / CI

- **GitHub Actions**: repository secret `OPENAI_API_KEY`, exposed as `env: OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}`
- **1Password / pass / sops**: inject into the environment before `gibbon`, not into tracked files
- **direnv**: `.envrc` with `dotenv` (add `.envrc` to `.gitignore` if it contains secrets)

Placeholder value for documentation only: see `.env.example` (`sk-replace-with-your-openai-api-key`).

## Quick start

```bash
cd ~/dev/gibbon-example/mini-api-open-ai

chmod +x scripts/render-chart.sh
./scripts/render-chart.sh

cp .env.example .env
# edit .env, then:
set -a && source .env && set +a

gibbon -v
```

Gibbon will apply each `instructions` entry in `gibbon.yaml` to every file in `templates/*.yaml`, committing after each step.

## Refresh manifests after chart changes

```bash
./scripts/render-chart.sh
git add templates/
```

## Customize OpenAI model

Edit `engine-options.model` in `gibbon.yaml` (e.g. `gpt-4o-mini`, `gpt-4o`).
