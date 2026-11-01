# Changelog

## 7.0.1.0

Security: the Docker image is rebuilt on PHP 8.5.12, which fixes the "php2shell" vulnerabilities (CVE-2026-109618, CVE-2026-109619). This container only runs PHP from the command line and doesn't serve HTTP requests, which the published attacks rely on, so the practical risk was low. Updating is still recommended. (#45)

- Docker builds now always pull the latest base image, and a manual rebuild workflow lets base-image security updates be shipped without a code change.
- No changes to the update script itself. If you don't use Docker, you don't need to do anything.

## 7.0.0.1

Based on [dynamic-dns-netcup-api v7.0.0](https://github.com/stecklars/dynamic-dns-netcup-api/releases/tag/v7.0.0).

**New features:**
* **CloudDNS support.** New `clouddns_domains` and `clouddns_dyndns_apikey` options for domains managed through netcup's new CloudDNS system. Mixed setups (some classic, some CloudDNS) work in a single run.
* **Pure-CloudDNS setups** no longer require `customer_number`, `api_key`, or `api_password`.

**Changes:**
* `customer_number`, `api_key`, `api_password`, and `domains` are now optional — required only when using classic CCP DNS domains.

**Bugfix:**
* Remove `clouddns_dyndns_apikey` and `clouddns_dyndns_apiurl` from default options — empty string defaults failed HA's `url?` / `password?` schema validation on install.

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
