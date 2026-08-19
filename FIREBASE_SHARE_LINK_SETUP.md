# Liquid Phim share links

The app shares URLs in this format:

```text
https://movieapp-c3847.web.app/movie/<slug>
```

Firebase Hosting temporarily redirects those requests to the Cloudflare Worker
at:

```text
https://liquid-phim-share.liquid-phim.workers.dev/movie/<slug>
```

The Worker loads the public PhimAPI detail response and renders server-side
Open Graph metadata (`og:title`, `og:description`, and `og:image`) so
messaging/social apps can build a movie preview card. The account-level
Cloudflare subdomain is `liquid-phim.workers.dev`; Cloudflare automatically
prefixes it with the Worker name `liquid-phim-share`.

## Deploy

```bash
npx wrangler@4.59.1 deploy \
  --config cloudflare/movie-share/wrangler.jsonc
```

Wrangler is pinned to `4.59.1` because that version supports the Node 20 runtime
currently installed on this machine. Then deploy Firebase Hosting only:

```bash
firebase login
firebase deploy --only hosting --project movieapp-c3847
```

This setup does not deploy Firebase Cloud Functions and therefore does not
require the Firebase Blaze plan. Supabase Edge Functions are not used because
Supabase rewrites HTML responses to `text/plain`.

## Android signing

`public/.well-known/assetlinks.json` currently contains the SHA-256 fingerprint
of the debug signing key because this project also uses that key for its current
release build. Add the production Play App Signing certificate fingerprint
before publishing a release signed by a different key.

## Verify after deployment

```bash
curl -I https://movieapp-c3847.web.app/.well-known/assetlinks.json
curl -I https://movieapp-c3847.web.app/.well-known/apple-app-site-association
curl -I https://movieapp-c3847.web.app/movie/phu-thuy-trang-diem-phan-5
node -e "fetch('https://movieapp-c3847.web.app/movie/phu-thuy-trang-diem-phan-5').then(async r => console.log(r.status, r.headers.get('content-type'), await r.text()))"
```

Both association files must return HTTP 200 with `Content-Type:
application/json`. The movie URL must first return HTTP 302 to Cloudflare, and
the final page must return `Content-Type: text/html` with the movie-specific
`og:title` and `og:image` values.

The older system `curl`/LibreSSL on some macOS versions can fail its TLS
handshake with a newly created `workers.dev` hostname. Use the Node `fetch`
command above for the end-to-end check in that case.

After changing associated domains, uninstall and reinstall the iOS/Android app
so the operating system verifies the domain again. Social platforms may cache
an older preview for a URL; use a new movie URL or their sharing debugger when
retesting.
