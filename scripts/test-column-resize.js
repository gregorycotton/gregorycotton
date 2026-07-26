const assert = require('node:assert/strict');
const { boundColumnResizeDelta } = require('./table-manager.js');

assert.equal(boundColumnResizeDelta(25, 100, 100, 70, 80), 20);
assert.equal(boundColumnResizeDelta(-100, 100, 100, 70, 80), -30);
assert.equal(boundColumnResizeDelta(10, 100, 100, 70, 80), 10);

console.log('Column resize bounds passed.');
