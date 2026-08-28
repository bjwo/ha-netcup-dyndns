# Changelog

## 7.0.0

Based on [dynamic-dns-netcup-api v7.0.0](https://github.com/stecklars/dynamic-dns-netcup-api/releases/tag/v7.0.0).

**New features:**
* **CloudDNS support.** New `clouddns_domains` and `clouddns_dyndns_apikey` options for domains managed through netcup's new CloudDNS system. Mixed setups (some classic, some CloudDNS) work in a single run.
* **Pure-CloudDNS setups** no longer require `customer_number`, `api_key`, or `api_password`.

**Changes:**
* `customer_number`, `api_key`, `api_password`, and `domains` are now optional — required only when using classic CCP DNS domains.

## 6.2.1

Hotfix release on top of v6.2.

**Bugfix:**
* **`TZ` env var now actually takes effect inside the container.**

## 6.2

**New features:**
* **Configure the Docker container via environment variables.**
* **Schedule-aware Docker `HEALTHCHECK`.**
* **Fail-fast Docker startup.**

**Bugfixes:**
* **Malformed API responses no longer leak PHP warnings.**
* **`DOMAINLIST` parsing rejects malformed entries cleanly.**
* **`USE_IPV6` is no longer required in `config.php`.**
* **`TZ` is now respected for cron-fired runs in Docker mode.**

## 6.1

- Initial release as Home Assistant app
- Based on [dynamic-dns-netcup-api v6.1](https://github.com/stecklars/dynamic-dns-netcup-api/releases/tag/v6.1)
- IPv4 and IPv6 support
- Configurable cron schedule
