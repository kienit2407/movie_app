const assert = require("node:assert/strict");
const test = require("node:test");

const originalFetch = global.fetch;
global.fetch = async () => ({
  ok: true,
  json: async () => ({
    movie: {
      name: "Phù Thủy Trang Điểm (Phần 5)",
      content: "<p>Nội dung phim</p>",
      poster_url: "https://img.phimapi.com/poster.jpg",
    },
  }),
});

const {
  handleMovieSharePage,
} = require("../../../functions/movie_share_page.js");

test.after(() => {
  global.fetch = originalFetch;
});

test("renders movie Open Graph metadata", async () => {
  const headers = new Map();
  let statusCode = 0;
  let html = "";
  const response = {
    setHeader(name, value) {
      headers.set(name, value);
    },
    end(value) {
      html = String(value ?? "");
    },
    get statusCode() {
      return statusCode;
    },
    set statusCode(value) {
      statusCode = value;
    },
  };

  await handleMovieSharePage(
    {url: "/movie/phu-thuy-trang-diem-phan-5"},
    response,
  );

  assert.equal(response.statusCode, 200);
  assert.equal(headers.get("Content-Type"), "text/html; charset=utf-8");
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
