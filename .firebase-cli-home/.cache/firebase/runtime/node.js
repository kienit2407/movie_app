(function() {
  const execArgv = [];
  let script = "";
  const scriptArgv = [];

  /*
  When invoked, this script is passed arguments like...
     node {optional node args starting with --} script {args to the script}
  We loop through the args to split them properly for when we call.fork()
   */
  process.argv.slice(2).forEach((arg) => {
    if (!script) {
      if (arg.startsWith("--")) {
        execArgv.push(arg);
      } else {
        script = arg;
      }
    } else {
      scriptArgv.push(arg);
    }
  });

  require("child_process")
    .fork(script, scriptArgv, {
      env: process.env,
      cwd: process.cwd(),
      stdio: "inherit",
      execArgv
    })
    .on("exit", code => {
      process.exit(code);
    });
})()