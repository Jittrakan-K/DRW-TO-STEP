const fs = require('fs');
const path = require('path');

const sldprtBuf = fs.readFileSync(path.join(__dirname, 'outputs', 'JIG-MOT097Z001-0.sldprt'));
const stepBuf = fs.readFileSync(path.join(__dirname, 'outputs', 'JIG-MOT097Z001-0_AP203.step'));

const sldprtB64 = sldprtBuf.toString('base64');
const stepB64 = stepBuf.toString('base64');

console.log('SLDPRT size:', sldprtBuf.length, 'bytes, B64 length:', sldprtB64.length);
console.log('STEP size:', stepBuf.length, 'bytes, B64 length:', stepB64.length);

const cadAssetsPath = path.join(__dirname, 'public', 'cad_assets.js');
let content = fs.readFileSync(cadAssetsPath, 'utf8');

// Replace JIG_SLDPRT_BASE64
const sldprtRegex = /const JIG_SLDPRT_BASE64 = "[^"]*";/;
if (sldprtRegex.test(content)) {
    content = content.replace(sldprtRegex, `const JIG_SLDPRT_BASE64 = "${sldprtB64}";`);
    console.log('Replaced JIG_SLDPRT_BASE64 in public/cad_assets.js');
} else {
    console.error('Could not find JIG_SLDPRT_BASE64 regex match!');
}

// Replace JIG_STEP_BASE64
const stepRegex = /const JIG_STEP_BASE64 = "[^"]*";/;
if (stepRegex.test(content)) {
    content = content.replace(stepRegex, `const JIG_STEP_BASE64 = "${stepB64}";`);
    console.log('Replaced JIG_STEP_BASE64 in public/cad_assets.js');
} else {
    console.error('Could not find JIG_STEP_BASE64 regex match!');
}

fs.writeFileSync(cadAssetsPath, content, 'utf8');

// Also update static/cad_assets.js
const staticAssetsPath = path.join(__dirname, 'static', 'cad_assets.js');
fs.writeFileSync(staticAssetsPath, content, 'utf8');
console.log('Updated static/cad_assets.js');

// Now rebuild standalone html
require('./build_standalone.js');
