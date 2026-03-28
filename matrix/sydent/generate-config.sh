#!/bin/bash
# Generate Sydent config from template
set -e

# Load environment variables
source ../../.env

# Generate config from template
envsubst < sydent.conf.template > sydent.conf

echo "✅ Generated sydent.conf from template"
