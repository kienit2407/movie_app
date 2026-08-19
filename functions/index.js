const {onRequest} = require("firebase-functions/v2/https");
const {handleMovieSharePage} = require("./movie_share_page");

exports.movieSharePage = onRequest(
  {region: "asia-southeast1", timeoutSeconds: 15, memory: "256MiB"},
  handleMovieSharePage,
);
