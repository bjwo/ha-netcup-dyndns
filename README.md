# Netcup Dynamic DNS - Home Assistant App

A Home Assistant app that automatically updates your [netcup](https://www.netcup.de) DNS records with your current public IP address. Supports both IPv4 (A records) and IPv6 (AAAA records).

This app wraps the excellent [dynamic-dns-netcup-api](https://github.com/stecklars/dynamic-dns-netcup-api) by [@stecklars](https://github.com/stecklars) into a Home Assistant app, so you can manage your dynamic DNS directly from your Home Assistant instance without needing a separate Docker container or cron job.

## Prerequisites

You need the following from your netcup account:

1. **Customer number** - Your netcup customer ID
2. **API key** - Generate one in the [netcup Customer Control Panel (CCP)](https://ccp.netcup.net) under "Master data" > "API"
3. **API password** - Generated together with the API key

Your DNS zone must already exist in netcup's DNS settings, and the records you want to update (A/AAAA) should be created beforehand.

## Installation

1. In Home Assistant, navigate to **Settings** > **Add-ons** > **Add-on Store**
2. Click the **three dots** menu (top right) and select **Repositories**
3. Add the following repository URL:
   ```
   https://github.com/bjwo/ha-netcup-dyndns
   ```
4. Click **Add**, then close the dialog
5. Find **Netcup Dynamic DNS** in the store and click **Install**
6. Configure the app (see below) and start it

## Configuration

Configuration is done through the Home Assistant UI - no need to manually edit a `config.php` file as with the standalone Docker image.

### Required options

| Option | Description |
|--------|-------------|
| `customer_number` | Your netcup customer number (e.g. `12345`) |
| `api_key` | Your netcup API key |
| `api_password` | Your netcup API password |
| `domains` | List of domain entries to update (see below) |

### Domains

Use the **Add** button in the UI to add one or more domain entries. Each entry has two fields:

| Field | Description |
|-------|-------------|
| `domain` | The domain name (e.g. `example.com`) |
| `hosts` | Comma-separated list of hosts to update for that domain |

**Host examples:**

- `@` — The root domain itself
- `*` — Wildcard record
- `www, mail` — Specific subdomains
- `@, *, www` — Root, wildcard, and www combined

### Optional options

| Option | Default | Description |
|--------|---------|-------------|
| `use_ipv4` | `true` | Enable IPv4 address detection and A record updates |
| `use_ipv6` | `false` | Enable IPv6 address detection and AAAA record updates |
| `change_ttl` | `true` | Automatically lower TTL to 300 seconds when an update is needed |
| `cron_schedule` | `*/5 * * * *` | How often to check for IP changes (cron expression) |
| `ipv4_address_url` | `https://get-ipv4.steck.cc` | Primary URL to detect your public IPv4 address |
| `ipv4_address_url_fallback` | `https://ipv4.seeip.org` | Fallback URL for IPv4 detection |
| `ipv6_address_url` | `https://get-ipv6.steck.cc` | Primary URL to detect your public IPv6 address |
| `ipv6_address_url_fallback` | `https://v6.ident.me` | Fallback URL for IPv6 detection |
| `jitter_max` | `30` | Maximum random delay in seconds before each update (helps distribute API load) |

## Differences from the standalone Docker image

| Aspect | Standalone Docker | Home Assistant App |
|--------|-------------------|--------------------|
| Configuration | Mount a `config.php` file | Configure via the app UI (visual domain list) |
| Scheduling | `CRON_SCHEDULE` env var | `cron_schedule` option in app config |
| Timezone | `TZ` env var | Inherited from Home Assistant |
| IP cache | Docker volume at `/app/data` | Managed automatically by the app |
| Lifecycle | Manual (Docker restart policies) | Managed by Home Assistant |

## How it works

1. On startup, the app reads your configuration and generates the required `config.php` for the upstream tool
2. It immediately performs a DNS update check
3. A cron job then runs at the configured schedule (default: every 5 minutes)
4. On each run, it detects your current public IP and compares it to the cached value
5. If the IP has changed, it updates your netcup DNS records via the API
6. The current IP is cached to avoid unnecessary API calls

## Logs

Check the app logs in the Home Assistant UI to see update activity. The log will show:
- When an IP change is detected
- Successful DNS record updates
- Any errors (e.g. API authentication failures)

## Credits

This app is a Home Assistant wrapper around [dynamic-dns-netcup-api](https://github.com/stecklars/dynamic-dns-netcup-api) by [stecklars](https://github.com/stecklars), licensed under the [MIT License](https://github.com/stecklars/dynamic-dns-netcup-api/blob/master/LICENSE).

All DNS update logic, IP detection, and netcup API interaction is provided by the upstream project. This app only adds the Home Assistant integration layer (configuration UI, lifecycle management).

## License

MIT License - See [LICENSE](LICENSE) for details.
