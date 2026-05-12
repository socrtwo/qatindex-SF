/* QAT Command Index — service worker
 * Strategy:
 *   - Navigation requests (HTML)          : network-first, fallback to cached shell
 *   - Same-origin static assets           : cache-first
 *   - SheetJS CDN script                  : cache-first (immutable URL with version)
 *   - Microsoft XLSX (raw.githubusercontent.com) : stale-while-revalidate
 *   - Anything else                       : pass-through
 */
const VERSION   = 'v3';
const SHELL     = `qat-shell-${VERSION}`;
const RUNTIME   = `qat-runtime-${VERSION}`;
const XLSX_CACHE= `qat-xlsx-${VERSION}`;

const SHELL_ASSETS = [
  './',
  './index.html',
  './manifest.json',
  './icons/icon-192.png',
  './icons/icon-512.png',
  './icons/icon-maskable-512.png',
  './icons/apple-touch-icon.png',
  './icons/favicon-32.png',
  './icons/favicon-16.png',
  './icons/icon.svg',
  'https://cdn.jsdelivr.net/npm/xlsx@0.18.5/dist/xlsx.full.min.js',
];

const MS_XLSX_HOST = 'raw.githubusercontent.com';

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(SHELL).then((cache) =>
      Promise.all(
        SHELL_ASSETS.map(async (url) => {
          try {
            await cache.add(new Request(url, { cache: 'reload' }));
          } catch (e) {
            // Cross-origin opaque adds can fail; ignore and let runtime caching handle it.
          }
        })
      )
    ).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const names = await caches.keys();
      await Promise.all(
        names
          .filter((n) => n.startsWith('qat-') && ![SHELL, RUNTIME, XLSX_CACHE].includes(n))
          .map((n) => caches.delete(n))
      );
      await self.clients.claim();
    })()
  );
});

self.addEventListener('message', (event) => {
  if (event.data === 'SKIP_WAITING') self.skipWaiting();
});

function isHTMLRequest(req) {
  return req.mode === 'navigate' ||
    (req.method === 'GET' && req.headers.get('accept')?.includes('text/html'));
}

async function staleWhileRevalidate(req, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(req);
  const network = fetch(req)
    .then((resp) => {
      if (resp && (resp.ok || resp.type === 'opaque')) cache.put(req, resp.clone());
      return resp;
    })
    .catch(() => null);
  return cached || network || new Response('Offline', { status: 503, statusText: 'Offline' });
}

async function cacheFirst(req, cacheName) {
  const cache = await caches.open(cacheName);
  const cached = await cache.match(req);
  if (cached) return cached;
  try {
    const resp = await fetch(req);
    if (resp && (resp.ok || resp.type === 'opaque')) cache.put(req, resp.clone());
    return resp;
  } catch (e) {
    return new Response('Offline', { status: 503, statusText: 'Offline' });
  }
}

async function networkFirst(req, cacheName) {
  const cache = await caches.open(cacheName);
  try {
    const resp = await fetch(req);
    if (resp && resp.ok) cache.put(req, resp.clone());
    return resp;
  } catch (e) {
    const cached = await cache.match(req) || await caches.match('./index.html') || await caches.match('./');
    return cached || new Response('Offline', { status: 503, statusText: 'Offline' });
  }
}

self.addEventListener('fetch', (event) => {
  const req = event.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);

  // Navigation / HTML: network-first so updates land, with offline fallback.
  if (isHTMLRequest(req)) {
    event.respondWith(networkFirst(req, SHELL));
    return;
  }

  // Microsoft's XLSX dataset: stale-while-revalidate for fast, offline-friendly loads.
  if (url.hostname === MS_XLSX_HOST) {
    event.respondWith(staleWhileRevalidate(req, XLSX_CACHE));
    return;
  }

  // SheetJS CDN — versioned URL, cache aggressively.
  if (url.hostname === 'cdn.jsdelivr.net') {
    event.respondWith(cacheFirst(req, RUNTIME));
    return;
  }

  // Same-origin static assets — cache-first.
  if (url.origin === self.location.origin) {
    event.respondWith(cacheFirst(req, SHELL));
    return;
  }

  // Other cross-origin: just pass through.
});
