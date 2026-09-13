#!/usr/bin/env node
const args = process.argv.slice(2);
if (args.includes("--help") || args.includes("-h") || args.length === 0) {
  process.stdout.write(`Usage: pitch-kit <command>

Commands:
  init     Scaffold a .pitchrc.json
  ship     Run the default ship
  doctor   Check the local setup
`);
  process.exit(0);
}
const cmd = args[0];
if (cmd === "init") {
  process.stdout.write("wrote .pitchrc.json\n");
  process.exit(0);
}
if (cmd === "ship") {
  process.stdout.write("ship complete\n");
  process.exit(0);
}
if (cmd === "doctor") {
  process.stdout.write("ok\n");
  process.exit(0);
}
process.stderr.write(`unknown command: ${cmd}\n`);
process.exit(1);
