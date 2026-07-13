// Service worker for Daoji landing / marketing PWA (not Flutter web).
// Bump CACHE_NAME on every release that changes shell assets.
const CACHE_NAME = "daoji-site-v2";
const APP_SHELL = [
  "./",
  "./index.html",
  "./assets/css/styles.css",
  "./assets/js/app.js",
  "./favicon.svg",
  "./apple-touch-icon.png",
  "./icon-192.png",
  "./icon-512.png",
  "./manifest.webmanifest",
  "./og-image.png",
];

/** Precache shell; tolerate individual 404s so one missing asset does not fail install. */
async function precacheShell() {
  const cache = await caches.open(CACHE_NAME);
  await Promise.all(
    APP_SHELL.map(async (url) => {
      try {
        const response = await fetch(url, { cache: "reload" });
        if (response.ok) {
          await cache.put(url, response);
        }
      } catch (_) {
        // Offline / missing asset — skip; runtime fetch may still fill later.
      }
    }),
  );
}

self.addEventListener("install", (event) => {
  event.waitUntil(precacheShell().then(() => self.skipWaiting()));
});

self.addEventListener("activate", (event) => {
  event.waitUntil(
    caches
      .keys()
      .then((keys) =>
        Promise.all(
          keys
            .filter((key) => key.startsWith("daoji-site-") && key !== CACHE_NAME)
            .map((key) => caches.delete(key)),
        ),
      )
      .then(() => self.clients.claim()),
  );
});

function isNavigationRequest(request) {
  return (
    request.mode === "navigate" ||
    (request.method === "GET" &&
      request.headers.get("accept") &&
      request.headers.get("accept").includes("text/html"))
  );
}

function isShellAsset(url) {
  const path = url.pathname;
  return (
    path.endsWith(".css") ||
    path.endsWith(".js") ||
    path.endsWith(".png") ||
    path.endsWith(".svg") ||
    path.endsWith(".webmanifest") ||
    path.endsWith("favicon.ico")
  );
}

self.addEventListener("fetch", (event) => {
  if (event.request.method !== "GET") return;
  const url = new URL(event.request.url);
  if (url.origin !== self.location.origin) return;

  // Network-first for navigations / HTML so deploy updates surface without hard-clear.
  if (isNavigationRequest(event.request)) {
    event.respondWith(
      (async () => {
        try {
          const network = await fetch(event.request);
          if (network.ok) {
            const cache = await caches.open(CACHE_NAME);
            event.waitUntil(cache.put("./index.html", network.clone()));
          }
          return network;
        } catch (_) {
          const cached =
            (await caches.match(event.request)) ||
            (await caches.match("./index.html")) ||
            (await caches.match("./"));
          if (cached) return cached;
          return new Response("Offline", {
            status: 503,
            statusText: "Offline",
            headers: { "Content-Type": "text/plain" },
          });
        }
      })(),
    );
    return;
  }

  // Cache-first for hashed/static shell assets; revalidate in background.
  if (isShellAsset(url)) {
    event.respondWith(
      caches.match(event.request).then((cached) => {
        const network = fetch(event.request)
          .then((response) => {
            if (response.ok) {
              const copy = response.clone();
              event.waitUntil(
                caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy)),
              );
            }
            return response;
          })
          .catch(() => cached);
        return cached || network;
      }),
    );
    return;
  }

  // Default: network with cache fallback
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        if (response.ok) {
          const copy = response.clone();
          event.waitUntil(
            caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy)),
          );
        }
        return response;
      })
      .catch(() => caches.match(event.request)),
  );
});
