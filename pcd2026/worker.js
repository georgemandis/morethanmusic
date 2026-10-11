// pcd2026.mand.is was the Processing Community Day 2026 workshop site. The site moved to morethanmusic.dev
// and became the standing resource; every old path has a page or a redirect there (website/static/_redirects).
// The home page goes to the workshop's own entry under Talks. Everything else keeps its path and query.
const HOST = 'https://morethanmusic.dev';
export default {
  fetch(request) {
    const url = new URL(request.url);
    const path = url.pathname === '/' ? '/talks/pcd-2026-nyc/' : url.pathname;
    return Response.redirect(HOST + path + url.search, 301);
  },
};
