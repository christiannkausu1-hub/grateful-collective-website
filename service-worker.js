const CACHE='grateful-collective-v18';
const CACHE_PREFIX='grateful-collective-';
const CORE=['/','/index.html','/manifest.webmanifest','/gc-192.png','/gc-512.png','/school-logo.jpg'];
self.addEventListener('install',event=>event.waitUntil(caches.open(CACHE).then(cache=>cache.addAll(CORE)).then(()=>self.skipWaiting())));
self.addEventListener('activate',event=>event.waitUntil(caches.keys().then(keys=>Promise.all(keys.filter(key=>key.startsWith(CACHE_PREFIX)&&key!==CACHE).map(key=>caches.delete(key)))).then(()=>self.clients.claim())));
self.addEventListener('fetch',event=>{
 const request=event.request;if(request.method!=='GET')return;const url=new URL(request.url);if(url.origin!==self.location.origin)return;
 event.respondWith((async()=>{try{const response=await fetch(request);if(response&&response.ok){const cache=await caches.open(CACHE);await cache.put(request,response.clone()).catch(()=>{});}return response;}catch(error){const cache=await caches.open(CACHE);const cached=await cache.match(request);if(cached)return cached;if(request.mode==='navigate'){const shell=await cache.match('/index.html');if(shell)return shell;}return new Response('You are offline and this resource is not available.',{status:503,statusText:'Offline',headers:{'Content-Type':'text/plain; charset=utf-8'}});}})());
});
