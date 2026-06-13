// ═══ Domain control — gateway-only access ═══
// This site should only be reached through https://alamedapointbg.com/freshpet/
// (the apbg-gateway proxy). The gateway stamps every proxied request with an
// X-APBG-Proxy header; requests without it — i.e. direct hits on
// billfreshpet.netlify.app — get a 301 to the branded URL.
//
// Activation: enforcement is OFF until the APBG_PROXY_SECRET env var is set
// on this site (same value as the header in apbg-gateway/netlify.toml).
// Merge + deploy order: gateway first (so the header is being stamped), then
// this, then set the env var. Unset the env var to turn it back off.
//
// Deploy previews + branch deploys (hosts containing "--") stay directly
// accessible for development.

const GATEWAY = 'https://alamedapointbg.com';

function mapPath(pathname) {
  if (pathname === '/' || pathname === '/index.html') return '/freshpet/';
  if (pathname.startsWith('/freshpet/')) return pathname;
  return '/freshpet' + pathname;
}

export default async (request, context) => {
  const secret = Netlify.env.get('APBG_PROXY_SECRET');
  if (!secret) return context.next(); // fail open until configured
  if (request.headers.get('x-apbg-proxy') === secret) return context.next();

  const url = new URL(request.url);
  if (url.hostname.includes('--') || url.hostname === 'localhost') return context.next();

  return Response.redirect(GATEWAY + mapPath(url.pathname) + url.search, 301);
};

export const config = {
  path: '/*',
  excludedPath: ['/api/*', '/.netlify/*'],
};
