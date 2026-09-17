# Amass MCP server

Amass is a remote [MCP](https://modelcontextprotocol.io) server for life-science
research. It exposes one linked corpus — publications, clinical trials, drugs,
genes, regulatory approvals and patents — to Claude, ChatGPT, VS Code, Cursor and
any other MCP client.

This repository holds the [MCP Registry](https://modelcontextprotocol.io/registry/about)
listing (`server.json`). The server itself is a hosted service, so there is
nothing here to install or run.

## Connect

Amass speaks streamable HTTP with OAuth 2.1. Most clients need only the URL:

```
https://mcp.amass.tech/mcp
```

You will be redirected to sign in with your Amass account; new accounts are
provisioned automatically with trial credits. Clients that cannot complete an
OAuth flow can instead send an Amass API key (`amass_…`) as a bearer token.

Or install it from the registry by name: `tech.amass/amass`.

## What you get

Six Cores, cross-linked so you can move between them in a single query —
publications ↔ trials, trials ↔ drugs, drugs ↔ genes, drugs ↔ approvals, and
patents ↔ drugs/publications.

| Core | Contents |
| --- | --- |
| **BioMedCore** | 40M+ biomedical publications (PubMed/PMC-derived) with abstracts, authors, journal metadata, citations, MeSH terms and optional fulltext |
| **TrialCore** | 1.2M+ clinical trials (ClinicalTrials.gov + WHO ICTRP non-US registries) with phase, status, sponsor, conditions, interventions, enrollment and outcomes |
| **DrugCore** | 22K+ harmonized drugs/molecules (ChEMBL-anchored) with modality, clinical stage, chemical structure, synonyms and trade names |
| **GeneCore** | 43K+ harmonized genes (Ensembl-anchored) with biotype, RefSeq summary, tractability/safety intelligence and UniProt protein annotations |
| **RegulatoryCore** | Unified FDA + EMA authorizations with approval status, orphan designations, and parsed source documents (labels, SmPCs, reviews, EPARs) |
| **PatentCore** *(preview)* | Life-science patents (USPTO/EPO/WIPO subset) with full-text search, CPC/IPC classifications, assignees/inventors and patent families |

Each Core has a `search_amass_<core>_records` tool for discovery and a
`get_amass_<core>_record` tool for fetching a known identifier. RegulatoryCore
adds `get_amass_regulatorycore_document_section` for full source-document text,
and `send_feedback` reports data issues straight to the Amass data team.

Website: <https://amass.tech> · Platform: <https://platform.amass.tech> ·
API docs: <https://mcp.amass.tech/api/doc>

## License

[Apache-2.0](LICENSE).

---

## Maintainers

Everything below is the release runbook for this listing. It is not needed to
use the server.

`server.json` is the source of truth. The registry authenticates by DNS: a TXT
record on `amass.tech` carries the public half of an Ed25519 key, and CI signs
with the private half. That is why the listing is namespaced `tech.amass/…`
rather than under a GitHub org.

### Publishing a new version

1. Edit `server.json` and bump `version`.
2. Open a PR — CI validates the file, checks the version is not already
   published, and confirms `https://mcp.amass.tech/mcp` is up.
3. Merge, then tag:

   ```bash
   git tag vX.Y.Z && git push origin vX.Y.Z    # must match "version" in server.json
   ```

The tag must match `version` in `server.json` or the workflow fails.

The listing `version` tracks the major version of the deployed MCP server.

### One-time DNS auth setup

```bash
./scripts/setup-dns-auth.sh
```

Generates the keypair and prints the Cloudflare TXT record and the
`gh secret set` command for `MCP_PRIVATE_KEY`. Follow its four steps, then
delete the local `key.pem`.

### Publishing by hand

```bash
brew install mcp-publisher
mcp-publisher login dns --domain amass.tech \
  --private-key "$(openssl pkey -in key.pem -noout -text | grep -A3 'priv:' | tail -n +2 | tr -d ' :\n')"
mcp-publisher publish
```

Verify:

```bash
curl --get --data-urlencode "search=tech.amass/amass" \
  https://registry.modelcontextprotocol.io/v0.1/servers
```

### Constraints worth remembering

- **`description` is capped at 100 characters.** CI enforces this.
- **Published versions are immutable**, and servers currently **cannot be
  deleted or unpublished** — corrections ship as a new version.
- Do not name a release branch after its version; it collides with the tag and
  `git push origin vX.Y.Z` becomes ambiguous.
