# mini-api-regional — one gibbon.yaml, three regional flavours (LLM engine)

This example shows how a **single `gibbon.yaml`** can turn one set of inputs into
**three distinct deployments** using the Gibbon **LLM engine**.

## The idea

`templates/` contains three Deployments that are **byte-for-byte identical except for
one label** — `app.kubernetes.io/region` (`amer`, `emea`, `apac`):

```
templates/
  deployment-amer.yaml
  deployment-emea.yaml
  deployment-apac.yaml
```

The instructions in `gibbon.yaml` are *region-aware*: each one reads the region label
and edits the manifest accordingly. So the **same config + same starting manifest**
diverges into three flavours. Gibbon applies every input file with every instruction
and commits once per instruction, so you can watch the three manifests drift apart.

## Real-life business need

One customer-facing **greeting API**, rolled out per region with:

| Region | Default language (flavour) | Replicas (scaling) | Resources | Data residency |
|--------|----------------------------|--------------------|-----------|----------------|
| **amer** | `en_US.UTF-8` | 6 | largest | `us` |
| **emea** | `de_DE.UTF-8` | 3 | medium | `eu` + GDPR annotation |
| **apac** | `ja_JP.UTF-8` | 2 | smallest | `jp` |

The instruction layers are:

1. Common platform labels.
2. **Localization** — `DEFAULT_LOCALE` / `LANG` / `SUPPORTED_LOCALES` per region.
3. **Scaling** — `replicas` + container resources sized to regional traffic.
4. **Compliance** — `data-region` annotation (+ a GDPR flag for `emea` only).

## Run it

```bash
cd mini-api-regional
cp .env.example .env        # then put your real OpenAI key in .env
gibbon
```

The LLM engine edits the files **in place** (unlike the helm engine, which writes to
`output/`). After a run, the three files under `templates/` are your three finished
deployments — three languages, three scaling profiles, three compliance postures — all
produced from this one `gibbon.yaml`.

> Uses an OpenAI-compatible endpoint (`server_url: https://api.openai.com`,
> `model: gpt-4o-mini`). The key is read from `OPENAI_API_KEY` / `GIBBON_LLM_API_KEY`;
> never commit a real key.
