#!/usr/bin/env node
// Extract SVG fragments from the avataaars React library via server-side rendering.
//
// Prerequisites:
//   cd ../avataaars-generator && npm install cheerio --no-save --legacy-peer-deps
//
// Usage (from flutter_avataaars/):
//   cd ../avataaars-generator && NODE_PATH=./node_modules node ../flutter_avataaars/tools/extract_svg_fragments.js
//
// Output: tools/svg_fragments.json (used by generate_svg_data.py)

const React = require("react");
const ReactDOM = require("react-dom/server");
const Avatar = require("avataaars").default;
const cheerio = require("cheerio");
const fs = require("fs");
const path = require("path");

// ---- Configuration ----
// We render with known color values that act as sentinel colors.
// At runtime, AvatarColorMapper substitutes the actual chosen colors.
// The sentinel hex values are valid colors, so the output is valid SVG
// (enabling SVGO, browser preview, etc).
const SKIN_MARKER = "DarkBrown";
const HAIR_MARKER = "SilverGray";
const HAT_MARKER = "Red";
const CLOTHE_MARKER = "Pink";
const FACIAL_HAIR_MARKER = "Auburn";

function render(props) {
  return ReactDOM.renderToStaticMarkup(React.createElement(Avatar, {
    skinColor: SKIN_MARKER,
    hairColor: HAIR_MARKER,
    hatColor: HAT_MARKER,
    clotheColor: CLOTHE_MARKER,
    facialHairColor: FACIAL_HAIR_MARKER,
    ...props,
  }));
}

function renumber(html, prefix) {
  return html
    .replace(/react-path-(\d+)/g, `${prefix}path-$1`)
    .replace(/react-mask-(\d+)/g, `${prefix}mask-$1`)
    .replace(/react-filter-(\d+)/g, `${prefix}filter-$1`);
}

function extractGroup($, selector, prefix, colorReplacements) {
  const el = $(selector).first();
  if (!el.length) return "";
  let html = $.html(el);

  // Check for external references and inline them
  const allRefs = new Set();
  let m;
  const reRef = /(?:xlink:href|href)="#([^"]+)"|url\(#([^)]+)\)/g;
  while ((m = reRef.exec(html)) !== null) {
    allRefs.add(m[1] || m[2]);
  }
  const definedIds = new Set();
  const reDef = /\bid="([^"]+)"/g;
  while ((m = reDef.exec(html)) !== null) {
    definedIds.add(m[1]);
  }
  const externalRefs = [...allRefs].filter(id => !definedIds.has(id));

  if (externalRefs.length > 0) {
    let inlineDefs = "";
    for (const ref of externalRefs) {
      const defEl = $(`defs [id="${ref}"]`);
      if (defEl.length) {
        inlineDefs += $.html(defEl);
      }
    }
    if (inlineDefs) {
      const firstClose = html.indexOf(">");
      html = html.substring(0, firstClose + 1) + "<defs>" + inlineDefs + "</defs>" + html.substring(firstClose + 1);
    }
  }

  html = renumber(html, prefix);

  if (colorReplacements) {
    for (const [hex, placeholder] of Object.entries(colorReplacements)) {
      html = html.split(hex).join(placeholder);
    }
  }

  return html;
}

// ---- Extract all components ----
const result = {};

// 1. Base components
console.log("Extracting base components...");
const baseSvg = render({});
const $base = cheerio.load(baseSvg, { xmlMode: true });

let sharedDefsHtml = "";
$base("svg > defs").children().each(function() {
  sharedDefsHtml += $base.html($base(this));
});
result.sharedDefs = renumber(sharedDefsHtml, "shared-");

result.body = extractGroup($base, "[id=Body]", "body-", {});

result.nose = extractGroup($base, '[id^="Nose/"]', "nose-", {});

// Color maps
result.skinColorMap = { Tanned: "#FD9841", Yellow: "#F8D25C", Pale: "#FFDBB4", Light: "#EDB98A", Brown: "#D08B5B", DarkBrown: "#AE5D29", Black: "#614335" };
result.hairColorMap = { Auburn: "#A55728", Black: "#2C1B18", Blonde: "#B58143", BlondeGolden: "#D6B370", Brown: "#724133", BrownDark: "#4A312C", Pastel: "#F59797", PastelPink: "#ECDCBF", Platinum: "#E8E1E1", Red: "#C93305", SilverGray: "#E8E1E1" };
result.clotheColorMap = { Black: "#262E33", Blue01: "#65C9FF", Blue02: "#5199E4", Blue03: "#25557C", Gray01: "#929598", Gray02: "#E6E6E6", Heather: "#3C4F5C", PastelBlue: "#B1E2FF", PastelGreen: "#A7FFC4", PastelOrange: "#FFDEB5", PastelRed: "#FFAFB9", PastelYellow: "#FFFFB1", Pink: "#FF488E", Red: "#FF5C5C", White: "#FFFFFF" };
result.hatColorMap = result.clotheColorMap;

// 2. Eye variants
const eyeTypes = ["Close", "Cry", "Default", "Dizzy", "EyeRoll", "Happy", "Hearts", "Side", "Squint", "Surprised", "Wink", "WinkWacky"];
result.eyes = {};
for (const et of eyeTypes) {
  console.log(`  Eyes: ${et}`);
  const svg = render({ eyeType: et });
  const $ = cheerio.load(svg, { xmlMode: true });
  result.eyes[et] = extractGroup($, '[id^="Eyes/"]', `eye${et}-`, {});
}

// 3. Eyebrow variants
const eyebrowTypes = ["Angry", "AngryNatural", "Default", "DefaultNatural", "FlatNatural", "RaisedExcited", "RaisedExcitedNatural", "SadConcerned", "SadConcernedNatural", "UnibrowNatural", "UpDown", "UpDownNatural"];
result.eyebrows = {};
for (const eb of eyebrowTypes) {
  console.log(`  Eyebrows: ${eb}`);
  const svg = render({ eyebrowType: eb });
  const $ = cheerio.load(svg, { xmlMode: true });
  result.eyebrows[eb] = extractGroup($, '[id^="Eyebrow/"]', `brow${eb}-`, {});
}

// 4. Mouth variants
const mouthTypes = ["Concerned", "Default", "Disbelief", "Eating", "Grimace", "Sad", "ScreamOpen", "Serious", "Smile", "Tongue", "Twinkle", "Vomit"];
result.mouths = {};
for (const mt of mouthTypes) {
  console.log(`  Mouths: ${mt}`);
  const svg = render({ mouthType: mt });
  const $ = cheerio.load(svg, { xmlMode: true });
  result.mouths[mt] = extractGroup($, '[id^="Mouth/"]', `mouth${mt}-`, {});
}

// 5. Clothing variants
const clotheTypes = ["BlazerShirt", "BlazerSweater", "CollarSweater", "GraphicShirt", "Hoodie", "Overall", "ShirtCrewNeck", "ShirtScoopNeck", "ShirtVNeck"];
result.clothing = {};
for (const ct of clotheTypes) {
  console.log(`  Clothing: ${ct}`);
  const svg = render({ clotheType: ct });
  const $ = cheerio.load(svg, { xmlMode: true });
  const clothingGroup = $('[id^="Clothing/"]').first();
  if (clothingGroup.length) {
    result.clothing[ct] = extractGroup($, '[id^="Clothing/"]', `clothe${ct}-`, {});
  }
}

// 6. Graphic shirt variants
const graphicTypes = ["Bat", "Cumbia", "Deer", "Diamond", "Hola", "Pizza", "Resist", "Selena", "Bear", "SkullOutline", "Skull"];
result.graphicClothing = {};
for (const gt of graphicTypes) {
  console.log(`  GraphicShirt+${gt}`);
  const svg = render({ clotheType: "GraphicShirt", graphicType: gt });
  const $ = cheerio.load(svg, { xmlMode: true });
  result.graphicClothing[gt] = extractGroup($, '[id^="Clothing/"]', `gshirt${gt}-`, {});
}

// 7. Top variants (hair/hats)
const topTypes = [
  "NoHair", "Eyepatch", "Hat", "Hijab", "Turban",
  "WinterHat1", "WinterHat2", "WinterHat3", "WinterHat4",
  "LongHairBigHair", "LongHairBob", "LongHairBun", "LongHairCurly",
  "LongHairCurvy", "LongHairDreads", "LongHairFrida", "LongHairFro",
  "LongHairFroBand", "LongHairMiaWallace", "LongHairNotTooLong",
  "LongHairShavedSides", "LongHairStraight", "LongHairStraight2",
  "LongHairStraightStrand",
  "ShortHairDreads01", "ShortHairDreads02", "ShortHairFrizzle",
  "ShortHairShaggyMullet", "ShortHairShortCurly", "ShortHairShortFlat",
  "ShortHairShortRound", "ShortHairShortWaved", "ShortHairSides",
  "ShortHairTheCaesar", "ShortHairTheCaesarSidePart",
];

const hatTypes = new Set(["Hat", "Hijab", "Turban", "WinterHat1", "WinterHat2", "WinterHat3", "WinterHat4"]);

// LongHairShavedSides uses hardcoded hair colors instead of the dynamic
// HairColor component. Replace the lighter fringe with the hair sentinel
// (main color) and keep the darker body as a "hair shadow" sentinel that
// ColorMapper will darken by 20% at runtime.
const SHAVED_SIDES_HAIR_FIXES = { '#E0C863': '#E8E1E1', '#CCB55A': '#CCB55A' };

result.top = {};
for (const tt of topTypes) {
  console.log(`  Top: ${tt}`);
  const svg = render({ topType: tt });
  const $ = cheerio.load(svg, { xmlMode: true });

  const topGroup = $("g[id^='Top']").first();
  if (!topGroup.length) continue;

  const colorFixes = tt === 'LongHairShavedSides' ? SHAVED_SIDES_HAIR_FIXES : {};
  result.top[tt] = extractGroup($, "g[id^='Top']", `top${tt}-`, colorFixes);
}

// 8. Accessory variants
const accessoryTypes = ["Blank", "Kurt", "Prescription01", "Prescription02", "Round", "Sunglasses", "Wayfarers"];
result.accessories = {};
for (const at of accessoryTypes) {
  console.log(`  Accessories: ${at}`);
  const svg = render({ accessoriesType: at });
  const $ = cheerio.load(svg, { xmlMode: true });

  const accEl = $('[id^="Top/_Resources/"]').first();
  if (accEl.length) {
    result.accessories[at] = extractGroup($, '[id^="Top/_Resources/"]', `acc${at}-`, {});
  } else {
    result.accessories[at] = "";
  }
}

// 9. Facial hair variants
const facialHairTypes = ["Blank", "BeardMedium", "BeardLight", "BeardMajestic", "MoustacheFancy", "MoustacheMagnum"];
result.facialHair = {};
for (const fh of facialHairTypes) {
  console.log(`  FacialHair: ${fh}`);
  const svg = render({ facialHairType: fh });
  const $ = cheerio.load(svg, { xmlMode: true });

  const fhEl = $('[id^="Facial-Hair/"]').first();
  if (fhEl.length) {
    result.facialHair[fh] = extractGroup($, '[id^="Facial-Hair/"]', `fh${fh}-`, {});
  } else {
    result.facialHair[fh] = "";
  }
}

// Write JSON alongside this script
const outputPath = path.join(__dirname, "svg_fragments.json");
fs.writeFileSync(outputPath, JSON.stringify(result, null, 0));
console.log(`\nExtraction complete. Written to ${outputPath}`);
console.log(`Eyes: ${Object.keys(result.eyes).length}`);
console.log(`Eyebrows: ${Object.keys(result.eyebrows).length}`);
console.log(`Mouths: ${Object.keys(result.mouths).length}`);
console.log(`Clothing: ${Object.keys(result.clothing).length}`);
console.log(`GraphicClothing: ${Object.keys(result.graphicClothing).length}`);
console.log(`Top: ${Object.keys(result.top).length}`);
console.log(`Accessories: ${Object.keys(result.accessories).length}`);
console.log(`FacialHair: ${Object.keys(result.facialHair).length}`);
