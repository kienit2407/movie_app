function appendToPath(isWin, pathsToAppend) {
  /*
    This method handles appending a folder to the user's PATH directory in a cross-platform way.

    Windows uses ";" to delimit paths and *nix uses ":"
   */
  const PATH = process.env.PATH;
  const pathSeperator = isWin ? ";" : ":";

  process.env.PATH = [
    ...pathsToAppend,
    ...PATH.split(pathSeperator).filter(folder => folder)
  ].join(pathSeperator);
}
async function getSafeCrossPlatformPath(isWin, path) {
  /*
    This function generates "safe" DOS style file paths on Windows.

    For example:

    unsafePath: C:\Program Files\Java\jdk1.6.0_22
    safePath: C:\PROGRA~1\Java\JDK16~1.0_2

    These paths remove spaces and special characters which could interfere with the terminal.
    In theory, it should be possible to avoid this, but because of issues in npm, we need to be
    extra safe about spaces.
   */
  if (!isWin) return path;

  /*
    This is perhaps the biggest hack in Firepit, we shell out to command and run a small script
    which returns the DOS-formatted version of a path. This is not fast, but it's (apparently)
    the only way to fetch the safe version of a path
   */
  let command = `for %I in ("${path}") do echo %~sI`;
  return new Promise(resolve => {
    const cmd = require("child_process").spawn(`cmd`, ["/c", command], {
      shell: true
    });

    let result = "";
    cmd.on("error", error => {
      throw error;
    });
    cmd.stdout.on("data", stdout => {
      result += stdout.toString();
    });

    cmd.on("close", code => {
      if (code === 0) {
        const lines = result.split("\r\n").filter(line => line);
        const path = lines.slice(-1)[0];
        resolve(path.trim());
      } else {
        throw `Attempt to dosify path failed with code ${code}`;
      }
    });
  });
}
(async function() {
  const path = require("path");
  const child_process = require("child_process");
  const isWin = process.platform === "win32";
  const args = process.argv.slice(2);

  appendToPath(isWin, [
    __dirname,
    path.join(process.cwd(), "node_modules/.bin")
  ]);

  let index;
  if ((index = args.indexOf("-c")) !== -1) {
    args.splice(index, 1);
  }

  args[0] = args[0].replace(process.execPath, "node");
  let [cmdRuntime, cmdScript, ...otherArgs] = args[0].split(" ");

  if (cmdRuntime === process.execPath) {
    cmdRuntime = "node";
  }

  let cmd;
  if (cmdRuntime === "node") {
    if ([".", "/"].indexOf(cmdScript[0]) === -1) {
      cmdScript = await getSafeCrossPlatformPath(
        isWin,
        path.join(process.cwd(), cmdScript)
      );
    }

    cmd = child_process.fork(cmdScript, otherArgs, {
      env: process.env,
      cwd: process.cwd(),
      stdio: "inherit"
    });
  } else {
    cmd = child_process.spawn(cmdRuntime, [cmdScript, ...otherArgs], {
      env: process.env,
      cwd: process.cwd(),
      stdio: "inherit",
      shell: true
    });
  }

  cmd.on("exit", code => {
    process.exit(code);
  });
})()