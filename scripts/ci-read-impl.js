const fs = require("fs");

function read(path) {
  if (!fs.existsSync(path)) return "";
  const raw = fs.readFileSync(path, "utf8");
  let j;
  try {
    j = JSON.parse(raw);
  } catch {
    return "";
  }
  const last = (Array.isArray(j) ? j : [j]).slice(-1)[0] || {};
  const a = String(last.implementation || "").trim().replace(/\s+/g, "");
  const ok = /^0x[0-9a-fA-F]{40}$/.test(a);
  return ok ? a : "";
}

const p = process.argv[2];
process.stdout.write(read(p));
