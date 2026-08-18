const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');

const loaderPath = path.join(__dirname, 'image-loader.js');
const {isCurrentRequest, navigationIndex} = require(loaderPath);

assert.equal(navigationIndex(0, -1, 3), -1);
assert.equal(navigationIndex(0, 1, 3), 1);
assert.equal(navigationIndex(2, 1, 3), -1);
assert.equal(navigationIndex(2, -1, 3), 1);
assert.equal(isCurrentRequest(4, 4), true);
assert.equal(isCurrentRequest(3, 4), false);

const source = fs.readFileSync(loaderPath, 'utf8');
assert.equal(source.includes('new Map('), false);
assert.equal(source.includes('URL.createObjectURL'), false);
assert.match(source, /request === currentRequest/);
assert.match(source, /document\.querySelectorAll\('\.image-resource-block'\)/);
assert.match(source, /prefers-reduced-motion: reduce/);
assert.match(source, /viewer\.addEventListener\('keydown'/);

console.log('image viewer controller self-tests passed');
