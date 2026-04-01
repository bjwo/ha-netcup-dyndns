#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Read app options
CUSTOMER_NUMBER=$(jq -r '.customer_number' "$CONFIG_PATH")
API_KEY=$(jq -r '.api_key' "$CONFIG_PATH")
API_PASSWORD=$(jq -r '.api_password' "$CONFIG_PATH")
DOMAIN_LIST=$(jq -r '[.domains[] | "\(.domain): \(.hosts)"] | join("; ")' "$CONFIG_PATH")
USE_IPV4=$(jq -r '.use_ipv4' "$CONFIG_PATH")
USE_IPV6=$(jq -r '.use_ipv6' "$CONFIG_PATH")
CHANGE_TTL=$(jq -r '.change_ttl' "$CONFIG_PATH")
CRON_SCHEDULE=$(jq -r '.cron_schedule' "$CONFIG_PATH")
IPV4_ADDRESS_URL=$(jq -r '.ipv4_address_url' "$CONFIG_PATH")
IPV4_ADDRESS_URL_FALLBACK=$(jq -r '.ipv4_address_url_fallback' "$CONFIG_PATH")
IPV6_ADDRESS_URL=$(jq -r '.ipv6_address_url' "$CONFIG_PATH")
IPV6_ADDRESS_URL_FALLBACK=$(jq -r '.ipv6_address_url_fallback' "$CONFIG_PATH")
JITTER_MAX=$(jq -r '.jitter_max' "$CONFIG_PATH")

# Validate required fields
if [ -z "$CUSTOMER_NUMBER" ] || [ "$CUSTOMER_NUMBER" = "null" ] || [ "$CUSTOMER_NUMBER" = "" ]; then
    echo "[ERROR] customer_number is required"
    exit 1
fi
if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ] || [ "$API_KEY" = "" ]; then
    echo "[ERROR] api_key is required"
    exit 1
fi
if [ -z "$API_PASSWORD" ] || [ "$API_PASSWORD" = "null" ] || [ "$API_PASSWORD" = "" ]; then
    echo "[ERROR] api_password is required"
    exit 1
fi
DOMAIN_COUNT=$(jq '.domains | length' "$CONFIG_PATH")
if [ "$DOMAIN_COUNT" -eq 0 ]; then
    echo "[ERROR] At least one domain entry is required"
    exit 1
fi

# Convert booleans to PHP
php_bool() {
    if [ "$1" = "true" ]; then echo "true"; else echo "false"; fi
}

# Generate config.php from app options
cat > /app/config.php <<EOPHP
<?php
define('CUSTOMERNR', '${CUSTOMER_NUMBER}');
define('APIKEY', '${API_KEY}');
define('APIPASSWORD', '${API_PASSWORD}');
define('DOMAINLIST', '${DOMAIN_LIST}');
define('USE_IPV4', $(php_bool "$USE_IPV4"));
define('USE_IPV6', $(php_bool "$USE_IPV6"));
define('CHANGE_TTL', $(php_bool "$CHANGE_TTL"));
define('IPV4_ADDRESS_URL', '${IPV4_ADDRESS_URL}');
define('IPV4_ADDRESS_URL_FALLBACK', '${IPV4_ADDRESS_URL_FALLBACK}');
define('IPV6_ADDRESS_URL', '${IPV6_ADDRESS_URL}');
define('IPV6_ADDRESS_URL_FALLBACK', '${IPV6_ADDRESS_URL_FALLBACK}');
define('JITTER_MAX', ${JITTER_MAX});
define('APIURL', 'https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON');
?>
EOPHP

echo "[INFO] Configuration generated successfully"
echo "[INFO] Domains: ${DOMAIN_LIST}"
echo "[INFO] IPv4: ${USE_IPV4}, IPv6: ${USE_IPV6}"
echo "[INFO] Cron schedule: ${CRON_SCHEDULE}"

# Export for the upstream entrypoint
export CRON_SCHEDULE

# Run the upstream entrypoint
exec /app/docker-entrypoint.sh
