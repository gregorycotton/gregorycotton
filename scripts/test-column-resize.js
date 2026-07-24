const assert = require('node:assert/strict');
const { boundColumnResizeDelta } = require('./table-manager.js');

assert.equal(boundColumnResizeDelta(25, 100, 100), 25);
assert.equal(boundColumnResizeDelta(-100, 100, 100), -40);
assert.equal(boundColumnResizeDelta(100, 100, 100), 40);

console.log('Column resize bounds passed.');
