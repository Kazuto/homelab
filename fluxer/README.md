# Fluxer

Self-hosted Discord-like messaging and VoIP platform.

## ⚠️ Experimental Setup

This is deployed **before official self-hosting support** is fully ready. The Fluxer developers are still working on making self-hosting easier and more lightweight. Expect potential issues.

## Configuration

- **URL**: https://fluxer.fae.sh
- **Port**: 8500
- **Database**: SQLite (stored in `/mnt/docker/data/fluxer/data/fluxer.db`)
- **Cache**: Valkey (Redis alternative)

## Current Setup

This is a minimal configuration with:
- ✅ SQLite database (simplest option)
- ✅ Valkey for caching/sessions
- ❌ Search (Meilisearch) - not enabled
- ❌ VoIP (LiveKit) - not enabled
- ❌ NATS messaging - config references it but not in docker-compose

## Known Issues / To-Do

1. **NATS missing**: The config template references NATS but it's not in our docker-compose. The app might fail on startup or certain features might not work.

2. **S3/Storage**: Using internal S3 endpoint (http://127.0.0.1:8080/s3) - unclear if this works or needs external S3.

3. **VAPID keys**: Not configured - push notifications won't work.

4. **First-time setup**: No idea what the initial admin setup flow looks like.

5. **Marketing module**: Disabled in config, might cause issues.

## Adding Optional Features

### Enable Search (Meilisearch)

Add to docker-compose.yml:
```yaml
  meilisearch:
    image: getmeili/meilisearch:v1.14
    container_name: fluxer-meilisearch
    restart: unless-stopped
    environment:
      - MEILI_ENV=production
      - MEILI_MASTER_KEY=${FLUXER_MEILI_KEY}
    volumes:
      - ${DOCKER_DATA_DIR}/fluxer/meilisearch:/meili_data
    networks:
      - fluxer
```

Then add to config.json:
```json
"integrations": {
  "search": {
    "engine": "meilisearch",
    "url": "http://meilisearch:7700",
    "api_key": "YOUR_MEILI_KEY"
  }
}
```

### Enable VoIP (LiveKit)

Requires many UDP ports (50000-50100) and additional configuration. See upstream compose.yaml for reference.

## Useful Commands

```bash
# Start Fluxer
cd /home/kazuto/Development/Private/homelab/fluxer
docker compose up -d

# View logs
docker compose logs -f fluxer

# Restart
docker compose restart fluxer

# Stop
docker compose down
```

## References

- GitHub: https://github.com/fluxerapp/fluxer
- Docs: https://docs.fluxer.app
- Upstream compose.yaml: https://github.com/fluxerapp/fluxer/blob/main/compose.yaml
