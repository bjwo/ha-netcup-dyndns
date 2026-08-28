#!/usr/bin/env bash
set -e

CONFIG_PATH=/data/options.json

# Read app options
CUSTOMER_NUMBER=$(jq -r '.customer_number // ""' "$CONFIG_PATH")
API_KEY=$(jq -r '.api_key // ""' "$CONFIG_PATH")
API_PASSWORD=$(jq -r '.api_password // ""' "$CONFIG_PATH")
DOMAIN_LIST=$(jq -r '[.domains[]? | "\(.domain): \(.hosts)"] | join("; ")' "$CONFIG_PATH")
DOMAIN_COUNT=$(jq '.domains | length' "$CONFIG_PATH")
CLOUDDNS_DOMAIN_LIST=$(jq -r '[.clouddns_domains[]? | "\(.domain): \(.hosts)"] | join("; ")' "$CONFIG_PATH")
CLOUDDNS_DOMAIN_COUNT=$(jq '.clouddns_domains | length' "$CONFIG_PATH")
CLOUDDNS_DYNDNS_APIKEY=$(jq -r '.clouddns_dyndns_apikey // ""' "$CONFIG_PATH")
CLOUDDNS_DYNDNS_APIURL=$(jq -r '.clouddns_dyndns_apiurl // ""' "$CONFIG_PATH")
USE_IPV4=$(jq -r '.use_ipv4' "$CONFIG_PATH")
USE_IPV6=$(jq -r '.use_ipv6' "$CONFIG_PATH")
CHANGE_TTL=$(jq -r '.change_ttl' "$CONFIG_PATH")
CRON_SCHEDULE=$(jq -r '.cron_schedule' "$CONFIG_PATH")
IPV4_ADDRESS_URL=$(jq -r '.ipv4_address_url' "$CONFIG_PATH")
IPV4_ADDRESS_URL_FALLBACK=$(jq -r '.ipv4_address_url_fallback' "$CONFIG_PATH")
IPV6_ADDRESS_URL=$(jq -r '.ipv6_address_url' "$CONFIG_PATH")
IPV6_ADDRESS_URL_FALLBACK=$(jq -r '.ipv6_address_url_fallback' "$CONFIG_PATH")
JITTER_MAX=$(jq -r '.jitter_max' "$CONFIG_PATH")

# Validate: at least one domain list must have entries
if [ "$DOMAIN_COUNT" -eq 0 ] && [ "$CLOUDDNS_DOMAIN_COUNT" -eq 0 ]; then
    echo "[ERROR] At least one domain must be configured in 'domains' or 'clouddns_domains'"
    exit 1
fi

# Classic CCP DNS domains require customer_number, api_key, api_password
if [ "$DOMAIN_COUNT" -gt 0 ]; then
    if [ -z "$CUSTOMER_NUMBER" ] || [ "$CUSTOMER_NUMBER" = "null" ]; then
        echo "[ERROR] customer_number is required when using classic domains"
        exit 1
    fi
    if [ -z "$API_KEY" ] || [ "$API_KEY" = "null" ]; then
        echo "[ERROR] api_key is required when using classic domains"
        exit 1
    fi
    if [ -z "$API_PASSWORD" ] || [ "$API_PASSWORD" = "null" ]; then
        echo "[ERROR] api_password is required when using classic domains"
        exit 1
    fi
fi

# CloudDNS domains require clouddns_dyndns_apikey
if [ "$CLOUDDNS_DOMAIN_COUNT" -gt 0 ]; then
    if [ -z "$CLOUDDNS_DYNDNS_APIKEY" ] || [ "$CLOUDDNS_DYNDNS_APIKEY" = "null" ]; then
        echo "[ERROR] clouddns_dyndns_apikey is required when using clouddns_domains"
        exit 1
    fi
fi

php_bool() {
    if [ "$1" = "true" ]; then echo "true"; else echo "false"; fi
}

# Generate config.php
{
    echo "<?php"

    if [ "$DOMAIN_COUNT" -gt 0 ]; then
        echo "define('CUSTOMERNR', '${CUSTOMER_NUMBER}');"
        echo "define('APIKEY', '${API_KEY}');"
        echo "define('APIPASSWORD', '${API_PASSWORD}');"
        echo "define('DOMAINLIST', '${DOMAIN_LIST}');"
    fi

    if [ "$CLOUDDNS_DOMAIN_COUNT" -gt 0 ]; then
        echo "define('DOMAINLIST_CLOUDDNS_DYNDNS', '${CLOUDDNS_DOMAIN_LIST}');"
        echo "define('CLOUDDNS_DYNDNS_APIKEY', '${CLOUDDNS_DYNDNS_APIKEY}');"
        if [ -n "$CLOUDDNS_DYNDNS_APIURL" ] && [ "$CLOUDDNS_DYNDNS_APIURL" != "null" ]; then
            echo "define('CLOUDDNS_DYNDNS_APIURL', '${CLOUDDNS_DYNDNS_APIURL}');"
        fi
    fi

    echo "define('USE_IPV4', $(php_bool "$USE_IPV4"));"
    echo "define('USE_IPV6', $(php_bool "$USE_IPV6"));"
    echo "define('CHANGE_TTL', $(php_bool "$CHANGE_TTL"));"
    echo "define('IPV4_ADDRESS_URL', '${IPV4_ADDRESS_URL}');"
    echo "define('IPV4_ADDRESS_URL_FALLBACK', '${IPV4_ADDRESS_URL_FALLBACK}');"
    echo "define('IPV6_ADDRESS_URL', '${IPV6_ADDRESS_URL}');"
    echo "define('IPV6_ADDRESS_URL_FALLBACK', '${IPV6_ADDRESS_URL_FALLBACK}');"
    echo "define('JITTER_MAX', ${JITTER_MAX});"
    echo "define('APIURL', 'https://ccp.netcup.net/run/webservice/servers/endpoint.php?JSON');"
} > /app/config.php

echo "[INFO] Configuration generated successfully"
[ "$DOMAIN_COUNT" -gt 0 ] && echo "[INFO] Classic domains: ${DOMAIN_LIST}"
[ "$CLOUDDNS_DOMAIN_COUNT" -gt 0 ] && echo "[INFO] CloudDNS domains: ${CLOUDDNS_DOMAIN_LIST}"
echo "[INFO] IPv4: ${USE_IPV4}, IPv6: ${USE_IPV6}"
echo "[INFO] Cron schedule: ${CRON_SCHEDULE}"

export CRON_SCHEDULE

exec /app/docker-entrypoint.sh
