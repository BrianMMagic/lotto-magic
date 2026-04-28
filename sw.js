var CACHE = 'lotto-ticket';
var TICKET = 'ticket.png';

self.addEventListener('install', function() { self.skipWaiting(); });

self.addEventListener('activate', function(e) {
  e.waitUntil(self.clients.claim());
});

self.addEventListener('fetch', function(e) {
  if (new URL(e.request.url).pathname.endsWith('/' + TICKET)) {
    e.respondWith(
      caches.open(CACHE).then(function(c) {
        return c.match(TICKET).then(function(r) {
          return r || new Response('No ticket generated yet', {status: 404});
        });
      })
    );
  }
});
