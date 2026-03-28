#!/usr/bin/env bash
# Generate Stoat configuration files from templates with secrets from .env

cd "$(dirname "$0")"

# Load environment variables
if [ -f "../.env" ]; then
    set -a
    source ../.env
    set +a
else
    echo "Error: ../.env file not found"
    exit 1
fi

echo "Generating Stoat configuration files..."

# Generate Revolt.toml (using | as delimiter to avoid issues with / in secrets)
cat config/Revolt.toml.template | \
    sed "s|RABBITMQ_PASSWORD|${STOAT_RABBITMQ_PASSWORD}|g" | \
    sed "s|MINIO_PASSWORD|${STOAT_MINIO_PASSWORD}|g" | \
    sed "s|VAPID_PRIVATE_KEY|${STOAT_VAPID_PRIVATE_KEY}|g" | \
    sed "s|VAPID_PUBLIC_KEY|${STOAT_VAPID_PUBLIC_KEY}|g" | \
    sed "s|FILES_ENCRYPTION_KEY|${STOAT_FILES_ENCRYPTION_KEY}|g" | \
    sed "s|LIVEKIT_KEY|${STOAT_LIVEKIT_KEY}|g" | \
    sed "s|LIVEKIT_SECRET|${STOAT_LIVEKIT_SECRET}|g" \
    > config/Revolt.toml

# Generate livekit.yml
cat config/livekit.yml.template | \
    sed "s|LIVEKIT_KEY_PLACEHOLDER|${STOAT_LIVEKIT_KEY}|g" | \
    sed "s|LIVEKIT_SECRET_PLACEHOLDER|${STOAT_LIVEKIT_SECRET}|g" \
    > config/livekit.yml

# Generate .env.web
cat config/.env.web.template | \
    sed "s|VAPID_PUBLIC_KEY_PLACEHOLDER|${STOAT_VAPID_PUBLIC_KEY}|g" \
    > config/.env.web

echo "✅ Configuration files generated successfully!"
echo ""
echo "Files updated:"
echo "  - config/Revolt.toml"
echo "  - config/livekit.yml"
echo "  - config/.env.web"
echo ""
echo "Next steps:"
echo "  1. Review the configuration files"
echo "  2. Run: docker compose up -d"
echo "  3. Access Stoat at https://chat.fae.sh"
