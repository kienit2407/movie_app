import assert from "node:assert/strict";
import test from "node:test";

import {
  handleMovieSharePage,
  movieSlugFromRequest,
} from "../../../cloudflare/movie-share/src/share_page.mjs";

const originalFetch = global.fetch;

test.after(() => {
  global.fetch = originalFetch;
});

test("reads the movie slug from the Worker path", () => {
  const request = new Request(
    "https://liquid-phim-share.example.workers.dev/movie/phim-moi",
  );

  assert.equal(movieSlugFromRequest(request), "phim-moi");
});

test("renders HTML and movie Open Graph metadata", async () => {
  global.fetch = async () => new Response(JSON.stringify({
    movie: {
      name: "Phù Thủy Trang Điểm (Phần 5)",
      content: "<p>Nội dung phim</p>",
      poster_url: "https://img.phimapi.com/poster.jpg",
    },
  }), {
    status: 200,
    headers: { "Content-Type": "application/json" },
  });

  const response = await handleMovieSharePage(new Request(
    "https://liquid-phim-share.example.workers.dev/movie/phu-thuy-trang-diem-phan-5",
  ));
  const html = await response.text();

  assert.equal(response.status, 200);
  assert.equal(response.headers.get("Content-Type"), "text/html; charset=utf-8");
  assert.match(html, /property="og:title" content="Phù Thủy Trang Điểm \(Phần 5\)"/);
  assert.match(
    html,
    /property="og:image" content="https:\/\/img\.phimapi\.com\/poster\.jpg"/,
  );
  assert.match(
    html,
    /property="og:url" content="https:\/\/movieapp-c3847\.web\.app\/movie\/phu-thuy-trang-diem-phan-5"/,
  );
});

test("rejects an invalid slug", async () => {
  const response = await handleMovieSharePage(new Request(
    "https://liquid-phim-share.example.workers.dev/movie/phim%20khong-hop-le",
  ));

  assert.equal(response.status, 404);
});

