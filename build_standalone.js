const fs = require('fs');
const path = require('path');

const publicDir = path.join(__dirname, 'public');

let html = fs.readFileSync(path.join(publicDir, 'index.html'), 'utf8');
const css = fs.readFileSync(path.join(publicDir, 'styles.css'), 'utf8');
const assets = fs.readFileSync(path.join(publicDir, 'cad_assets.js'), 'utf8');
const app = fs.readFileSync(path.join(publicDir, 'app.js'), 'utf8');

// Embed CSS
html = html.replace('<link rel="stylesheet" href="styles.css">', '<style>\n' + css + '\n</style>');

// Embed JS
const inlineScript = '<script>\n' + assets + '\n\n' + app + '\n</script>';
html = html.replace(/<script src="cad_assets\.js"><\/script>\s*<script src="app\.js"><\/script>/, inlineScript);

const outPath = path.join(__dirname, 'solidworks_studio.html');
fs.writeFileSync(outPath, html, 'utf8');

console.log('Successfully generated solidworks_studio.html at:', outPath);
console.log('Total file size:', fs.statSync(outPath).size, 'bytes');
