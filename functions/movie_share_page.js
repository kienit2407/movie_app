const SHARE_ORIGIN = "https://movieapp-c3847.web.app";
const FALLBACK_IMAGE = `${SHARE_ORIGIN}/liquid-phim-share.png`;

function escapeHtml(value) {
  return String(value ?? "")
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&#039;");
}

function plainText(value) {
  return String(value ?? "")
    .replace(/<[^>]*>/g, " ")
    .replace(/\s+/g, " ")
    .trim();
}

function absoluteImage(value) {
  const image = String(value ?? "").trim();
  if (!image) return FALLBACK_IMAGE;
  if (/^https?:\/\//i.test(image)) return image;
  return `https://phimimg.com/${image.replace(/^\/+/, "")}`;
}

function renderPage({slug, name, description, image}) {
  const canonicalUrl = `${SHARE_ORIGIN}/movie/${encodeURIComponent(slug)}`;
  const appUrl = `liquidphim://movie/${encodeURIComponent(slug)}`;
  const safeName = escapeHtml(name);
  const safeDescription = escapeHtml(description);
  const safeImage = escapeHtml(image);
  const safeCanonicalUrl = escapeHtml(canonicalUrl);
  const safeAppUrl = escapeHtml(appUrl);

  return `<!doctype html>
<html lang="vi">
  <head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width,initial-scale=1">
    <title>${safeName} | Liquid Phim</title>
    <meta name="description" content="${safeDescription}">
    <link rel="canonical" href="${safeCanonicalUrl}">
    <meta property="og:type" content="video.movie">
    <meta property="og:site_name" content="Liquid Phim">
    <meta property="og:locale" content="vi_VN">
    <meta property="og:title" content="${safeName}">
    <meta property="og:description" content="${safeDescription}">
    <meta property="og:url" content="${safeCanonicalUrl}">
    <meta property="og:image" content="${safeImage}">
    <meta property="og:image:secure_url" content="${safeImage}">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="${safeName}">
    <meta name="twitter:description" content="${safeDescription}">
    <meta name="twitter:image" content="${safeImage}">
    <style>
      *{box-sizing:border-box}body{margin:0;min-height:100vh;background:#080910;color:#fff;font-family:Inter,-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;display:grid;place-items:center;padding:24px}.card{width:min(440px,100%);background:#161723;border:1px solid rgba(255,255,255,.1);border-radius:24px;overflow:hidden;box-shadow:0 24px 80px rgba(0,0,0,.45)}.poster{width:100%;aspect-ratio:16/9;object-fit:cover;background:#222}.content{padding:22px}.brand{color:#f3bd55;font-size:13px;font-weight:800;letter-spacing:.12em;text-transform:uppercase}h1{font-size:25px;line-height:1.25;margin:10px 0 8px}.description{color:#aaabba;line-height:1.55;margin:0 0 20px;display:-webkit-box;-webkit-line-clamp:3;-webkit-box-orient:vertical;overflow:hidden}.button{display:block;padding:14px 18px;text-align:center;text-decoration:none;color:#111;font-weight:800;border-radius:14px;background:linear-gradient(135deg,#ffd36a,#e481c8)}
    </style>
  </head>
  <body>
    <main class="card">
      <img class="poster" src="${safeImage}" alt="Poster ${safeName}">
      <section class="content">
        <div class="brand">Liquid Phim</div>
        <h1>${safeName}</h1>
        <p class="description">${safeDescription}</p>
        <a class="button" href="${safeAppUrl}">Mở trong Liquid Phim</a>
      </section>
    </main>
  </body>
</html>`;
}

async function handleMovieSharePage(request, response) {
  const parts = request.url.split("?")[0].split("/").filter(Boolean);
  const movieIndex = parts.indexOf("movie");
  const encodedSlug =
    movieIndex >= 0 ? parts[movieIndex + 1] ?? "" : parts[0] ?? "";
  let slug = "";
  try {
    slug = decodeURIComponent(encodedSlug);
  } catch (_) {
    response.statusCode = 404;
    response.end("Không tìm thấy phim.");
    return;
  }

  if (!slug || !/^[a-zA-Z0-9_-]+$/.test(slug)) {
    response.statusCode = 404;
    response.end("Không tìm thấy phim.");
    return;
  }

  let movie = null;
  try {
    const apiResponse = await fetch(
      `https://phimapi.com/phim/${encodeURIComponent(slug)}`,
      {headers: {accept: "application/json"}},
    );
    if (apiResponse.ok) {
      const payload = await apiResponse.json();
      movie = payload?.movie ?? null;
    }
  } catch (error) {
    console.error("[MovieSharePage] Movie API request failed", error);
  }

  const name = movie?.name || "Xem phim trên Liquid Phim";
  const description =
    plainText(movie?.content).slice(0, 220) ||
    `Xem ${name} trên ứng dụng Liquid Phim.`;
  const image = absoluteImage(movie?.poster_url || movie?.thumb_url);

  response.statusCode = 200;
  response.setHeader("Content-Type", "text/html; charset=utf-8");
  response.setHeader("Cache-Control", "public, max-age=300, s-maxage=3600");
  response.end(renderPage({slug, name, description, image}));
}

module.exports = {handleMovieSharePage, renderPage};
