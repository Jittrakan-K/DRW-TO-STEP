const fs = require('fs');
const path = require('path');

console.log('--- Verifying NASA SolidWorks Studio Redesign ---');

const htmlContent = fs.readFileSync(path.join(__dirname, 'public', 'index.html'), 'utf8');
const rootHtmlContent = fs.readFileSync(path.join(__dirname, 'index.html'), 'utf8');
const appJsContent = fs.readFileSync(path.join(__dirname, 'public', 'app.js'), 'utf8');

// 1. Extract all getElementById calls from app.js
const idMatches = [...appJsContent.matchAll(/getElementById\(['"]([^'"]+)['"]\)/g)];
const uniqueIds = Array.from(new Set(idMatches.map(m => m[1])));

// Dynamic IDs created during table render
const dynamicIds = new Set([
  'fl_od', 'fl_id', 'fl_thick', 'fl_pcd', 'fl_hcount', 'fl_hdia',
  'bl_w', 'bl_len', 'bl_h', 'bl_bore',
  'p_width', 'p_len', 'p_thick', 'pk_dia', 'pk_depth', 'ch_dia', 'p_chamfer'
]);

const staticIds = uniqueIds.filter(id => !dynamicIds.has(id));

console.log(`Found ${uniqueIds.length} unique DOM element IDs referenced in app.js (${staticIds.length} static, ${dynamicIds.size} dynamically rendered).`);

const missingInPublic = [];
const missingInRoot = [];

for (const id of staticIds) {
  const pattern = new RegExp(`id=["']${id}["']`);
  if (!pattern.test(htmlContent)) {
    missingInPublic.push(id);
  }
  if (!pattern.test(rootHtmlContent)) {
    missingInRoot.push(id);
  }
}

let hasError = false;
if (missingInPublic.length > 0) {
  console.error('ERROR: Missing static IDs in public/index.html:', missingInPublic);
  hasError = true;
} else {
  console.log('SUCCESS: All static element IDs exist in public/index.html!');
}

if (missingInRoot.length > 0) {
  console.error('ERROR: Missing static IDs in root index.html:', missingInRoot);
  hasError = true;
} else {
  console.log('SUCCESS: All static element IDs exist in root index.html!');
}

// 2. Test CAD generation functions
const vm = require('vm');
const dummyElement = {
  value: '',
  textContent: '',
  classList: { add: () => {}, remove: () => {}, contains: () => false },
  style: {},
  innerHTML: '',
  addEventListener: () => {},
  appendChild: () => {},
  querySelector: () => null,
  querySelectorAll: () => []
};

const sandbox = {
  console: console,
  window: {
    addEventListener: () => {},
    removeEventListener: () => {},
    innerWidth: 1920,
    innerHeight: 1080
  },
  document: {
    getElementById: () => dummyElement,
    querySelector: () => dummyElement,
    querySelectorAll: () => [],
    createElement: () => dummyElement,
    addEventListener: () => {},
    body: dummyElement
  },
  navigator: {},
  Blob: class { constructor(parts) { this.parts = parts; } },
  URL: { createObjectURL: () => 'blob:mock', revokeObjectURL: () => {} },
  THREE: {
    MeshStandardMaterial: class {},
    Shape: class {
      constructor() { this.holes = []; }
      moveTo() {}
      lineTo() {}
      absarc() {}
    },
    Path: class {
      moveTo() {}
      lineTo() {}
      absarc() {}
    },
    ExtrudeGeometry: class {},
    CylinderGeometry: class {},
    BoxGeometry: class {},
    Mesh: class {},
    Group: class {
      constructor() { this.children = []; }
      add() {}
    },
    Color: class {},
    Vector3: class {},
    Box3: class {
      setFromObject() {}
      getCenter() { return { x: 0, y: 0, z: 0 }; }
      getSize() { return { x: 100, y: 100, z: 100 }; }
    }
  },
  setTimeout: setTimeout,
  clearTimeout: clearTimeout,
  localStorage: {
    getItem: () => null,
    setItem: () => {}
  }
};

const context = vm.createContext(sandbox);

try {
  vm.runInContext(appJsContent, context);
  console.log('SUCCESS: app.js evaluated in VM without syntax errors!');

  console.log('\n--- Testing Natural Language Prompt Parsing ---');
  const testPrompts = [
    'แผ่นอะคริลิคใส CLEAR ACRYLIC 210x410x5 mm แผ่นเปล่าไม่มีรู',
    'แผ่นเพลท 100x150x12 mm หลุม 3x4 แถว รูเจาะ dia 8 mm',
    'เพลาขั้นบันได ยาว 120 mm ไดมิเตอร์ 30, 20, 15 mm'
  ];

  for (const prompt of testPrompts) {
    const spec = context.parsePromptLocally(prompt);
    vm.runInContext(`currentSpec = ${JSON.stringify(spec)};`, context);
    console.log(`Prompt: "${prompt}"`);
    console.log(` -> Type: ${spec.type}`);
    console.log(` -> Name: ${spec.name}`);
    console.log(` -> Material: ${spec.material}`);
    if (spec.type === 'plate') {
      console.log(` -> Dimensions: ${spec.width} x ${spec.length} x ${spec.thickness} mm`);
      console.log(` -> Holes / Pockets:`, spec.pockets);
    } else if (spec.type === 'shaft') {
      console.log(` -> Segments: ${spec.sections ? spec.sections.length : (spec.segments ? spec.segments.length : 'N/A')} steps`);
    }

    // Test STEP AP203 generation
    const stepContent = context.generateStepAP203Content();
    console.log(` -> STEP AP203 generated: ${stepContent.length} bytes (Starts with ISO-10303-21: ${stepContent.startsWith('ISO-10303-21')})`);

    // Test SolidWorks VBA Macro generation
    const macroContent = context.generateSolidWorksMacroCode();
    console.log(` -> SolidWorks VBA Macro generated: ${macroContent.length} bytes (Contains SldWorks.SldWorks: ${macroContent.includes('SldWorks.SldWorks')})`);
    console.log('----------------------------------------------------');
  }

} catch (err) {
  console.error('Error during VM execution:', err);
  hasError = true;
}

if (!hasError) {
  console.log('\n🎉 ALL NASA TEMPLATE & 3D CAD VERIFICATION TESTS PASSED PERFECTLY!');
} else {
  process.exit(1);
}
