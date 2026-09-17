#!/usr/bin/env bash
#
# Generates the Ed25519 keypair that proves control of amass.tech to the MCP
# Registry, and prints the DNS TXT record to add in Cloudflare.
#
# Run this once, from the repo root:
#
#     ./scripts/setup-dns-auth.sh
#
# It writes ./key.pem (gitignored). The PRIVATE key never leaves this machine
# except into 1Password and the GitHub Actions secret — do not paste it into
# chat, a ticket, or a PR.
set -euo pipefail

DOMAIN="amass.tech"

if [[ -f key.pem ]]; then
  echo "key.pem already exists — refusing to overwrite it." >&2
  echo "Delete it first if you really mean to rotate the key (this invalidates" >&2
  echo "the published TXT record until you update it)." >&2
  exit 1
fi

openssl genpkey -algorithm Ed25519 -out key.pem
chmod 600 key.pem

PUBLIC_KEY="$(openssl pkey -in key.pem -pubout -outform DER | tail -c 32 | base64)"

cat <<EOF

────────────────────────────────────────────────────────────────────────
STEP 1 — Add this TXT record in Cloudflare (zone: ${DOMAIN})

  Type:  TXT
  Name:  @            (i.e. ${DOMAIN} itself, alongside the existing SPF record)
  Value: v=MCPv1; k=ed25519; p=${PUBLIC_KEY}

STEP 2 — Store the private key, which is in ./key.pem

  a) 1Password: attach key.pem to a new item, e.g. "MCP Registry signing key".
  b) GitHub secret, so CI can publish:

       gh secret set MCP_PRIVATE_KEY \\
         --repo amass-technologies/amass-mcp \\
         --body "\$(openssl pkey -in key.pem -noout -text | grep -A3 'priv:' | tail -n +2 | tr -d ' :\\n')"

STEP 3 — Wait for propagation, then confirm the record is live:

  dig +short TXT ${DOMAIN} | grep MCPv1

STEP 4 — Publish (see README).

Once STEP 2 is done, delete the local copy:  rm key.pem
────────────────────────────────────────────────────────────────────────

EOF
