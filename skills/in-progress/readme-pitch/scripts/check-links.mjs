#!/usr/bin/env node
/**
 * Check relative markdown links and anchors in the given files.
 * GitHub slugger semantics: lowercase, strip punctuation, each space becomes
 * a hyphen, no collapsing of consecutive hyphens. Duplicate headings get
 * -1, -2, ... suffixes.
 *
 * Usage: node check-links.mjs [--root DIR] FILE [FILE...]
 * Exit 0 if all resolve, 1 if any are broken, 2 on usage error.
 */

import fs from "node:fs";
import path from "node:path";

const SKIP_SCHEMES =
  /^(https?:|mailto:|ftp:|irc:|tel:|data:|javascript:)/i;

class GithubSlugger {
  constructor() {
    this.occurrences = Object.create(null);
  }

  slug(value) {
    if (typeof value !== "string") return "";
    let slug = value
      .toLowerCase()
      .replace(/[^\p{L}\p{M}\p{N}\p{Pc}\- ]/gu, "")
      .trim()
      .replace(/ /g, "-");
    const original = slug;
    while (Object.prototype.hasOwnProperty.call(this.occurrences, slug)) {
      this.occurrences[original] += 1;
      slug = `${original}-${this.occurrences[original]}`;
    }
    this.occurrences[slug] = 0;
    return slug;
  }
}

function stripHeadingMarkup(text) {
  let s = text;
  s = s.replace(/!\[([^\]]*)\]\([^)]*\)/g, "$1");
  s = s.replace(/\[([^\]]+)\]\([^)]*\)/g, "$1");
  s = s.replace(/`/g, "");
  s = s.replace(/[*_]/g, "");
  s = s.replace(/<[^>]+>/g, "");
  return s.trim();
}

function blankOutFences(text) {
  return text.replace(/```[\s\S]*?```/g, (block) =>
    block.replace(/[^\n]/g, " "),
  );
}

function blankOutInlineCode(text) {
  return text.replace(/`[^`\n]+`/g, (m) => " ".repeat(m.length));
}

function collectHeadings(text) {
  const body = blankOutFences(text);
  const slugger = new GithubSlugger();
  const slugs = new Set();
  for (const line of body.split(/\r?\n/)) {
    const atx = /^(#{1,6})\s+(.+?)\s*#*\s*$/.exec(line);
    if (atx) slugs.add(slugger.slug(stripHeadingMarkup(atx[2])));
  }
  const htmlIds = [
    ...text.matchAll(/\bid=["']([^"']+)["']/gi),
    ...text.matchAll(/\bname=["']([^"']+)["']/gi),
  ];
  for (const m of htmlIds) slugs.add(m[1]);
  return slugs;
}

function parseArgs(argv) {
  let root = process.cwd();
  const files = [];
  for (let i = 0; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--root") {
      i += 1;
      if (!argv[i]) {
        console.error("check-links.mjs: --root needs a directory");
        process.exit(2);
      }
      root = path.resolve(argv[i]);
    } else if (a === "--help" || a === "-h") {
      console.log(
        "Usage: node check-links.mjs [--root DIR] FILE [FILE...]\n" +
          "Checks relative links and anchors. GitHub slugger, no collapsing.",
      );
      process.exit(0);
    } else {
      files.push(a);
    }
  }
  return { root, files };
}

function splitUrl(raw) {
  const trimmed = raw.trim().replace(/^<|>$/g, "");
  const titleCut = trimmed.replace(/\s+["'][^"']*["']\s*$/, "");
  const hash = titleCut.indexOf("#");
  if (hash === -1) return { href: titleCut, anchor: null };
  return { href: titleCut.slice(0, hash), anchor: titleCut.slice(hash + 1) };
}

function extractTargets(text) {
  const body = blankOutInlineCode(blankOutFences(text));
  const found = [];

  const md = /!?\[(?:[^\]]*)\]\(([^)]+)\)/g;
  let m;
  while ((m = md.exec(body)) !== null) {
    found.push(m[1]);
  }

  const refs = /^\s*\[([^\]]+)\]:\s+(\S+)/gm;
  while ((m = refs.exec(body)) !== null) {
    found.push(m[2]);
  }

  const href = /\b(?:href|src)=["']([^"']+)["']/gi;
  while ((m = href.exec(body)) !== null) {
    found.push(m[1]);
  }

  return found;
}

function resolveTarget(fromFile, raw, root) {
  const { href, anchor } = splitUrl(raw);
  if (!href && !anchor) return { skip: true };
  if (href && SKIP_SCHEMES.test(href)) return { skip: true };
  if (href.startsWith("//")) return { skip: true };

  let targetFile = fromFile;
  if (href) {
    if (href.startsWith("/")) {
      targetFile = path.resolve(root, href.replace(/^\/+/, ""));
    } else {
      targetFile = path.resolve(path.dirname(fromFile), href);
    }
  }
  return { targetFile, anchor, skip: false };
}

function headingCache(file, cache) {
  if (cache.has(file)) return cache.get(file);
  if (!fs.existsSync(file) || !fs.statSync(file).isFile()) {
    cache.set(file, null);
    return null;
  }
  const slugs = collectHeadings(fs.readFileSync(file, "utf8"));
  cache.set(file, slugs);
  return slugs;
}

function main() {
  const { root, files } = parseArgs(process.argv.slice(2));
  const targets = files.length > 0 ? files : ["README.md"];
  const cache = new Map();
  const broken = [];
  let checked = 0;

  for (const rel of targets) {
    const fromFile = path.resolve(root, rel);
    if (!fs.existsSync(fromFile)) {
      broken.push(`${rel}: file does not exist (cannot scan)`);
      continue;
    }
    const text = fs.readFileSync(fromFile, "utf8");
    for (const raw of extractTargets(text)) {
      const resolved = resolveTarget(fromFile, raw, root);
      if (resolved.skip) continue;
      checked += 1;
      const { targetFile, anchor } = resolved;
      if (!fs.existsSync(targetFile)) {
        broken.push(`${rel} -> ${raw} (missing file)`);
        continue;
      }
      if (anchor) {
        const slugs = headingCache(targetFile, cache);
        if (!slugs || !slugs.has(anchor)) {
          broken.push(`${rel} -> ${raw} (missing anchor)`);
        }
      }
    }
  }

  if (broken.length === 0) {
    console.log(`LINKS: all resolve (${checked} checked)`);
    process.exit(0);
  }
  for (const line of broken) console.log(`BROKEN  ${line}`);
  console.log(`LINKS: ${broken.length} broken`);
  process.exit(1);
}

main();
