# Fluxer Configuration

## Setup Instructions

Generate secrets and create config.json from the template:

```bash
# Generate secrets (run this once)
cat >> ../../.env << 'EOF'

# Fluxer secrets
FLUXER_S3_SECRET=$(openssl rand -hex 32)
FLUXER_MEDIA_SECRET=$(openssl rand -hex 32)
FLUXER_ADMIN_SECRET=$(openssl rand -hex 32)
FLUXER_OAUTH_SECRET=$(openssl rand -hex 32)
FLUXER_MARKETING_SECRET=$(openssl rand -hex 32)
FLUXER_GATEWAY_SECRET=$(openssl rand -hex 32)
FLUXER_SUDO_SECRET=$(openssl rand -hex 32)
FLUXER_CONNECTION_SECRET=$(openssl rand -hex 32)
EOF

# Generate config.json from template
source ../../.env
envsubst < config.json.template > config.json
```

## Files

- `config.json.template` - Template with env var placeholders (committed to git)
- `config.json` - Generated config with actual secrets (gitignored, not committed)
