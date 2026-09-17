# Amass MCP server — registry listing

This repo holds the [MCP Registry](https://modelcontextprotocol.io/registry/about)
listing for the Amass MCP server. It is metadata only: the server itself is a
hosted service at `https://mcp.amass.tech/mcp`.

## Connecting to the server

Amass is a remote MCP server using streamable HTTP and OAuth 2.1. Most clients
only need the URL:

```
https://mcp.amass.tech/mcp
```

Your client will be redirected to sign in with your Amass account.
The server exposes search and get tools over linked life-science Cores.

Website: <https://amass.tech> · Platform: <https://platform.amass.tech>

## How publishing works

`server.json` is the source of truth for the listing. The registry authenticates
by DNS: a TXT record on `amass.tech` carries the public half of an Ed25519
key, and CI signs with the private half. That is why the listing is namespaced
`tech.amass/…` rather than under a GitHub org.

### One-time setup

```bash
./scripts/setup-dns-auth.sh
```

This generates the keypair and prints the Cloudflare TXT record and the
`gh secret set` command for `MCP_PRIVATE_KEY`. Follow its four steps, then
delete the local `key.pem`.

### Publishing a new version

1. Edit `server.json` and bump `version`.
2. Open a PR — CI validates the file, checks the version is not already
   published, and confirms `https://mcp.amass.tech/mcp` is up.
3. Merge, then tag:

   ```bash
   git tag v6.0.0 && git push origin v6.0.0
   ```

The tag must match `version` in `server.json` or the workflow fails.

### Publishing by hand

```bash
brew install mcp-publisher
mcp-publisher login dns --domain amass.tech \
  --private-key "$(openssl pkey -in key.pem -noout -text | grep -A3 'priv:' | tail -n +2 | tr -d ' :\n')"
mcp-publisher publish
```

Verify:

```bash
curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=tech.amass/amass"
```

## Things to know before changing `server.json`

- **`description` is capped at 100 characters.** CI enforces this.
- **Published versions are immutable**, and servers currently **cannot be
  deleted or unpublished** — corrections ship as a new version.
- The `version` here describes *the listing*, not the deployed build.