import { handleMovieSharePage } from "./share_page.mjs";

export default {
  fetch(request) {
    return handleMovieSharePage(request);
  },
};

