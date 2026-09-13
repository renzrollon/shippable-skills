import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { test } from "node:test";
import { fileURLToPath } from "node:url";

const readme = readFileSync(
  join(dirname(fileURLToPath(import.meta.url)), "..", "README.md"),
  "utf8",
);

test("readme keeps the init command pin", () => {
  assert.ok(readme.includes("npx pitch-kit init"));
});

test("readme keeps the Node compatibility pin", () => {
  assert.ok(readme.includes("Compatible with Node.js 20.19 or newer"));
});

test("readme keeps the license pin", () => {
  assert.ok(readme.includes("License: MIT"));
});
