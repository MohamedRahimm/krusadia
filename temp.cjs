
const path = require('path');
const fs = require('fs');
const EXPORT_DIR = path.join(__dirname, 'godot/export');
const files = fs.readdirSync(EXPORT_DIR);

if (files.length === 0) {
  console.log("✔ Export folder is empty — skipping move.");
  process.exit(0);
}
