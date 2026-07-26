const assert = require('node:assert/strict');
const { boundColumnResizeDelta, fitColumnWidths } = require('./table-manager.js');

assert.equal(boundColumnResizeDelta(25, 100, 100, 70, 80), 20);
assert.equal(boundColumnResizeDelta(-100, 100, 100, 70, 80), -30);
assert.equal(boundColumnResizeDelta(10, 100, 100, 70, 80), 10);

assert.deepEqual(fitColumnWidths([200, 300], [100, 150], 500), {
    tableWidth: 500,
    widths: [200, 300]
});
assert.deepEqual(fitColumnWidths([200, 300], [250, 350], 500), {
    tableWidth: 600,
    widths: [250, 350]
});

console.log('Column resize checks passed.');
