// Responsible for all DOM manipulation related to rendering the data table and handling data sorting logic.

function escapeHtml(value) {
    return String(value)
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

const resizedTableColumns = {};
const minimumColumnWidth = 60;

function boundColumnResizeDelta(delta, leftWidth, rightWidth) {
    return Math.max(
        minimumColumnWidth - leftWidth,
        Math.min(delta, rightWidth - minimumColumnWidth)
    );
}

function applyColumnWidths(table, columns, widths, tableWidth) {
    let colgroup = table.querySelector('colgroup[data-resizable-columns]');
    if (!colgroup) {
        colgroup = document.createElement('colgroup');
        colgroup.dataset.resizableColumns = '';
        table.insertBefore(colgroup, table.firstChild);
    }

    if (colgroup.children.length !== widths.length) {
        colgroup.replaceChildren(...widths.map(() => document.createElement('col')));
    }
    widths.forEach((width, index) => {
        colgroup.children[index].style.width = `${width}px`;
    });
    table.style.width = `${tableWidth}px`;
    table.classList.add('columns-resized');
    resizedTableColumns[table.id] = { columns: columns.join('|'), widths, tableWidth };
}

function setupColumnResizing(table, columns) {
    const storedWidths = resizedTableColumns[table.id];
    if (storedWidths?.columns === columns.join('|')) {
        applyColumnWidths(table, columns, storedWidths.widths, storedWidths.tableWidth);
    } else {
        table.querySelector('colgroup[data-resizable-columns]')?.remove();
        table.style.removeProperty('width');
        table.classList.remove('columns-resized');
    }

    const headers = Array.from(table.querySelectorAll('thead th'));
    headers.slice(0, -1).forEach((th, index) => {
        const handle = document.createElement('span');
        handle.className = 'column-resizer';
        handle.setAttribute('role', 'separator');
        handle.tabIndex = 0;
        handle.setAttribute('aria-label', `Resize ${columns[index]} column`);
        handle.setAttribute('aria-orientation', 'vertical');
        handle.setAttribute('aria-valuemin', minimumColumnWidth);
        th.appendChild(handle);

        const initialWidth = th.getBoundingClientRect().width;
        const adjacentWidth = headers[index + 1].getBoundingClientRect().width;
        handle.setAttribute('aria-valuenow', Math.round(initialWidth));
        handle.setAttribute('aria-valuemax', Math.round(initialWidth + adjacentWidth - minimumColumnWidth));

        const resizeBy = delta => {
            const widths = headers.map(header => header.getBoundingClientRect().width);
            const tableWidth = table.getBoundingClientRect().width;
            const boundedDelta = boundColumnResizeDelta(delta, widths[index], widths[index + 1]);
            widths[index] += boundedDelta;
            widths[index + 1] -= boundedDelta;
            applyColumnWidths(table, columns, widths, tableWidth);
            handle.setAttribute('aria-valuenow', Math.round(widths[index]));
        };

        handle.addEventListener('keydown', event => {
            if (!['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
            event.preventDefault();
            event.stopPropagation();
            resizeBy(event.key === 'ArrowLeft' ? -10 : 10);
        });

        handle.addEventListener('pointerdown', event => {
            event.preventDefault();
            event.stopPropagation();

            const startX = event.clientX;
            const startWidths = headers.map(header => header.getBoundingClientRect().width);
            const tableWidth = table.getBoundingClientRect().width;
            th.classList.add('column-resize-hover');
            handle.setPointerCapture(event.pointerId);

            const move = moveEvent => {
                const boundedDelta = boundColumnResizeDelta(
                    moveEvent.clientX - startX,
                    startWidths[index],
                    startWidths[index + 1]
                );
                const widths = [...startWidths];
                widths[index] += boundedDelta;
                widths[index + 1] -= boundedDelta;
                applyColumnWidths(table, columns, widths, tableWidth);
                handle.setAttribute('aria-valuenow', Math.round(widths[index]));
            };
            const finish = () => {
                th.classList.remove('column-resize-hover');
                handle.removeEventListener('pointermove', move);
                handle.removeEventListener('pointerup', finish);
                handle.removeEventListener('pointercancel', finish);
            };

            handle.addEventListener('pointermove', move);
            handle.addEventListener('pointerup', finish);
            handle.addEventListener('pointercancel', finish);
        });

        handle.addEventListener('pointerenter', () => th.classList.add('column-resize-hover'));
        handle.addEventListener('pointerleave', event => {
            if (!handle.hasPointerCapture(event.pointerId)) th.classList.remove('column-resize-hover');
        });
        handle.addEventListener('focus', () => th.classList.add('column-resize-hover'));
        handle.addEventListener('blur', () => th.classList.remove('column-resize-hover'));
    });
}

function renderTable(data, options = {}) {
    const { renderRows = true } = options;
    const config = getCurrentViewConfig();
    const table = document.getElementById(config.tableId);
    const thead = table.querySelector('thead');
    const tbody = table.querySelector('tbody');

    if (!thead || !tbody) {
        console.error(`Table elements not found for ID: ${config.tableId}`);
        return;
    }

    const validColumnsForView = config.columns;
    let effectiveColumns = columnPrefs[currentView]?.filter(col => validColumnsForView.includes(col));
    if (!effectiveColumns || effectiveColumns.length === 0) {
        console.warn(`Stored columns for ${currentView} view were invalid or empty. Resetting to default.`);
        effectiveColumns = defaultColumns[currentView];
        columnPrefs[currentView] = effectiveColumns;
        saveColumnPrefs();
        setupColumnSelectors();
    }
    currentColumns = effectiveColumns;

    const orderedColumns = validColumnsForView.filter(col => currentColumns.includes(col));

    thead.innerHTML = orderedColumns.map(col => {
        const isSorted = col === sortColumn;
        const arrow = isSorted ?
            (sortDirection === 'asc' ? '<span class="sort-arrow">▲</span>' : '<span class="sort-arrow">▼</span>') : '';

        let displayName = col;
        if (col === 'SizeBytes') {
            displayName = 'Size Bytes';
        } else if (col === 'FeaturedWork') {
            displayName = 'Featured';
        } else if (col === 'PublishedDate') {
            displayName = 'Published';
        } else if (col === 'LastUpdated') {
            displayName = 'Updated';
        } else if (col === 'ReadingTimeMinutes') {
            displayName = 'Reading Time';
        } else if (col === 'WordCount') {
            displayName = 'Word Count';
        } else if (col !== 'UUID') {
            displayName = col.replace(/([A-Z])/g, ' $1').trim();
        }
        return `<th class="sort-th">${displayName}${arrow}</th>`;
    }).join('');

    thead.querySelectorAll('th').forEach((th, index) => {
        const column = orderedColumns[index];
        th.addEventListener('click', event => {
            if (event.target.closest('.column-resizer')) return;
            if (sortColumn === column) {
                sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
            } else {
                sortColumn = column;
                sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated', 'ReadingTimeMinutes', 'WordCount'].includes(column) ? 'desc' : 'asc';
            }
            sortData();
            renderTable(currentData);
        });
    });

    setupColumnResizing(table, orderedColumns);

    if (!renderRows) {
        return;
    }

    tbody.innerHTML = data.map(item => {
        const rowContent = orderedColumns.map(col => {
            let value = item[col];

            if (currentView === 'ontology') {
                if (col === 'Title' && item.URL) {
                    value = `<a class="table-link" href="/ontology/${escapeHtml(item.URL)}.html">${escapeHtml(item[col] ?? 'N/A')}</a>`;
                } else if (['Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords'].includes(col)) {
                    value = Array.isArray(item[col]) ? item[col].join(', ') : (item[col] || 'N/A');
                } else if (col === 'FeaturedWork') {
                    value = item[col] === 'TRUE' ? 'TRUE' : 'FALSE';
                }
            } else if (currentView === 'fieldnotes') {
                if (col === 'Title' && item.URL) {
                    value = `<a class="table-link" href="/fieldnotes/${escapeHtml(item.URL)}.html">${escapeHtml(item[col] ?? 'N/A')}</a>`;
                } else if (['PublishedDate', 'LastUpdated'].includes(col) && value !== 'N/A') {
                    try {
                        const [year, month, day] = value.split('-');
                        if (year && month && day) {
                            value = `${day}/${month}/${year}`;
                        }
                    } catch (e) { /* Ignore formatting error */ }
                } else if (col === 'ReadingTimeMinutes' && value !== 'N/A') {
                    value = `${value} min`;
                } else if (col === 'WordCount' && value !== 'N/A') {
                    value = Number(value).toLocaleString();
                }
            // } else if (currentView === 'album') {
            //     if (col === 'SizeBytes' && value !== 'N/A') {
            //         value = Number(value).toLocaleString();
            //     } else if (col === 'FileName' && value !== 'N/A') {
            //         const fileName = item[col];
            //         value = `<a class="table-link" href="#" onclick="showImagePopup('${fileName}'); return false;">${fileName}</a>`;
            //     }
            }

            if (!(typeof value === 'string' && value.startsWith('<a '))) {
                value = escapeHtml(value ?? 'N/A');
            }
            return `<td>${value}</td>`;
        }).join('');
        return `<tr>${rowContent}</tr>`;
    }).join('');
}

function sortData() {
    const config = getCurrentViewConfig();
    if (!config.columns.includes(sortColumn)) {
        sortColumn = config.defaultSort;
        sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated', 'ReadingTimeMinutes', 'WordCount'].includes(sortColumn) ? 'desc' : 'asc';
    }

    currentData.sort((a, b) => {
        let valA = a[sortColumn];
        let valB = b[sortColumn];

        if (['Year', 'SizeBytes', 'ReadingTimeMinutes', 'WordCount'].includes(sortColumn)) {
            valA = parseInt(valA, 10) || 0;
            valB = parseInt(valB, 10) || 0;
        } else if (['PublishedDate', 'LastUpdated'].includes(sortColumn)) {
            valA = valA ?? '';
            valB = valB ?? '';
        } else if (Array.isArray(valA) || Array.isArray(valB)) {
            valA = Array.isArray(valA) ? valA.join(', ') : (valA ?? '');
            valB = Array.isArray(valB) ? valB.join(', ') : (valB ?? '');
        } else if (typeof valA === 'string' && typeof valB === 'string') {
            valA = valA.toLowerCase();
            valB = valB.toLowerCase();
        } else {
            valA = valA ?? '';
            valB = valB ?? '';
            if (typeof valA === 'string') valA = valA.toLowerCase();
            if (typeof valB === 'string') valB = valB.toLowerCase();
        }

        if (valA < valB) return sortDirection === 'asc' ? -1 : 1;
        if (valA > valB) return sortDirection === 'asc' ? 1 : -1;

        const titleA = String(a.Title ?? '').toLowerCase();
        const titleB = String(b.Title ?? '').toLowerCase();
        if (titleA < titleB) return -1;
        if (titleA > titleB) return 1;

        const uuidA = String(a.UUID ?? '').toLowerCase();
        const uuidB = String(b.UUID ?? '').toLowerCase();
        if (uuidA < uuidB) return -1;
        if (uuidA > uuidB) return 1;
        return 0;
    });
}

// Manages the overall state when a user switches between tables
// Reset state variables, trigger full data reload for the new view.
function getCurrentViewConfig() {
    switch (currentView) {
        case 'ontology':
            return {
                columns: ontologyColumns,
                tableId: 'projectsTable',
                viewId: 'ontologyView',
                apiBaseAction: 'projects',
                titleField: 'Title',
                defaultSort: 'Year',
                searchColumns: ['UUID', 'Title', 'ShortDescription', 'Year', 'Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords']
            };
        case 'fieldnotes':
            return {
                columns: fieldnotesColumns,
                tableId: 'fieldnotesTable',
                viewId: 'fieldnotesView',
                apiBaseAction: 'fieldnotes',
                titleField: 'Title',
                defaultSort: 'PublishedDate',
                searchColumns: ['UUID', 'Title', 'ShortDescription', 'PublishedDate', 'LastUpdated', 'WordCount', 'ReadingTimeMinutes']
            };
        // case 'album':
        //     return {
        //         columns: albumColumns,
        //         tableId: 'albumsTable',
        //         viewId: 'albumView',
        //         apiBaseAction: 'albums',
        //         titleField: 'FileName',
        //         defaultSort: 'Year'
        //     };
        default:
            console.error("Invalid view selected:", currentView, ". Falling back to ontology.");
            currentView = 'ontology';
            return {
                columns: ontologyColumns,
                tableId: 'projectsTable',
                viewId: 'ontologyView',
                apiBaseAction: 'projects',
                titleField: 'Title',
                defaultSort: 'Year',
                searchColumns: ['UUID', 'Title', 'ShortDescription', 'Year', 'Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords']
            };
    }
}

function normalizeView(view) {
    if (view === 'fieldnotes') return 'fieldnotes';
    return 'ontology';
}

function applyViewState(view) {
    currentView = normalizeView(view);
    const config = getCurrentViewConfig();

    document.getElementById('ontologyView').classList.toggle('hidden', currentView !== 'ontology');
    document.getElementById('fieldnotesView').classList.toggle('hidden', currentView !== 'fieldnotes');
    // document.getElementById('albumView').classList.toggle('hidden', currentView !== 'album');

    const selectedView = document.querySelector(`input[name="viewType"][value="${currentView}"]`);
    if (selectedView) selectedView.checked = true;

    currentColumns = columnPrefs[currentView];
    sortColumn = config.defaultSort;
    sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated', 'ReadingTimeMinutes', 'WordCount'].includes(sortColumn) ? 'desc' : 'asc';
    currentData = [];
}

function switchView(view, options = {}) {
    const { force = false, skipLoadData = false, skipUrlUpdate = false, replaceHistory = false } = options;
    const normalizedView = normalizeView(view);
    if (!force && currentView === normalizedView) return;

    applyViewState(normalizedView);
    document.getElementById('searchInput').value = '';
    clearQuery({ skipLoadData: true, skipUrlUpdate: true });
    toggleColumnSelector(true);

    setupColumnSelectors();
    if (!skipLoadData) {
        loadData();
    }
    if (!skipUrlUpdate) {
        updateQueryUrl([], { view: normalizedView, replaceHistory });
    }
}

// Modifying columns
// Dynamically generate column options based on the current view
function setupColumnSelectors() {
    const config = getCurrentViewConfig();
    const selector = document.getElementById('columnSelector');
    selector.innerHTML = '';

    const grid = document.createElement('div');
    grid.className = 'columns-grid';

    const columnsPerGroup = 3;

    const availableColumns = config.columns;
    const displayableColumns = availableColumns.filter(col => col !== 'UUID');

    const selectedColumns = columnPrefs[currentView];

    for (let i = 0; i < displayableColumns.length; i += columnsPerGroup) {
        const group = document.createElement('div');
        group.className = 'column-group';
        const slice = displayableColumns.slice(i, i + columnsPerGroup);

        slice.forEach(col => {

            const label = document.createElement('label');
            const checkbox = document.createElement('input');
            checkbox.type = 'checkbox';
            checkbox.value = col;
            checkbox.checked = Array.isArray(selectedColumns) && selectedColumns.includes(col);
            checkbox.addEventListener('change', handleColumnSelectionChange);
            label.appendChild(checkbox);

            let displayName = col;
            if (col === 'SizeBytes') {
                displayName = 'Size Bytes';
            } else if (col === 'FeaturedWork') {
                displayName = 'Featured';
            } else if (col === 'PublishedDate') {
                displayName = 'Published Date';
            } else if (col === 'LastUpdated') {
                displayName = 'Last Updated';
            } else if (col === 'ReadingTimeMinutes') {
                displayName = 'Reading Time';
            } else if (col === 'WordCount') {
                displayName = 'Word Count';
            } else {
                displayName = col.replace(/([A-Z])/g, ' $1').trim();
            }
            label.appendChild(document.createTextNode(` ${displayName}`));

            group.appendChild(label);
        });
        grid.appendChild(group);
    }
    selector.appendChild(grid);
}

function handleColumnSelectionChange() {
    const config = getCurrentViewConfig();
    const newlySelectedColumns = config.columns.filter(col =>
        document.querySelector(`#columnSelector input[value="${col}"]`)?.checked
    );

    if (newlySelectedColumns.length === 0) {
        currentColumns = defaultColumns[currentView];
        setupColumnSelectors();
    } else {
        currentColumns = newlySelectedColumns;
    }

    columnPrefs[currentView] = currentColumns;
    saveColumnPrefs();

    renderTable(currentData);
}

const URL_VIEW_PARAM = 'view';
const URL_QUERY_PARAM = 'query';
const URL_QUERY_SEPARATOR = '^';
const URL_OPERATOR_BY_QUERY_OPERATOR = {
    'IS': '=',
    'IS NOT': '!=',
    'CONTAINS': '~',
    'STARTS WITH': '*=',
    'ENDS WITH': '$=',
    'GREATER THAN': '>',
    'LESS THAN': '<',
    'PUBLISHED ON': '=',
    'UPDATED ON': '=',
    'PUBLISHED BEFORE': '<=',
    'UPDATED BEFORE': '<=',
    'PUBLISHED AFTER': '>=',
    'UPDATED AFTER': '>='
};
const URL_OPERATOR_TOKENS = ['>=', '<=', '!=', '*=', '$=', '=', '~', '>', '<'];

function getOperatorMapForView(view = currentView) {
    switch (view) {
        case 'ontology':
            return {
                'UUID': ['IS', 'CONTAINS', 'STARTS WITH', 'ENDS WITH'],
                'Title': ['IS', 'CONTAINS'],
                'ShortDescription': ['IS', 'CONTAINS', 'STARTS WITH', 'ENDS WITH'],
                'Year': ['IS', 'IS NOT', 'GREATER THAN', 'LESS THAN'],
                'Modality': ['IS', 'IS NOT'],
                'Medium': ['IS', 'IS NOT'],
                'Tools': ['IS', 'IS NOT'],
                'Object': ['IS', 'IS NOT'],
                'Collaborators': ['IS', 'IS NOT'],
                'Keywords': ['IS', 'IS NOT'],
                'FeaturedWork': ['IS']
            };
        case 'fieldnotes':
            return {
                'UUID': ['IS', 'CONTAINS', 'STARTS WITH', 'ENDS WITH'],
                'Title': ['IS', 'CONTAINS', 'STARTS WITH', 'ENDS WITH'],
                'ShortDescription': ['IS', 'CONTAINS', 'STARTS WITH', 'ENDS WITH'],
                'PublishedDate': ['PUBLISHED ON', 'PUBLISHED BEFORE', 'PUBLISHED AFTER'],
                'LastUpdated': ['UPDATED ON', 'UPDATED BEFORE', 'UPDATED AFTER'],
                'ReadingTimeMinutes': ['IS', 'IS NOT', 'GREATER THAN', 'LESS THAN'],
                'WordCount': ['IS', 'IS NOT', 'GREATER THAN', 'LESS THAN']
            };
        default:
            return {};
    }
}

function getOperatorsForField(field, view = currentView) {
    const map = getOperatorMapForView(view);
    return map[field] || ['IS', 'CONTAINS'];
}

function getCatalogueRows(view = currentView) {
    return catalogueData?.views?.[view]?.rows || [];
}

function getRecordValues(record, field) {
    const value = record[field];
    if (Array.isArray(value)) return value;
    return [value];
}

function conditionMatches(record, condition, view = currentView) {
    const field = condition.field;
    const operator = condition.operator;
    const expected = String(condition.value ?? '').trim();
    const rawValue = record[field];
    const values = getRecordValues(record, field).filter(value => value !== null && value !== undefined && value !== '');
    const normalizedValues = values.map(value => String(value));
    const metadataFields = ['Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords'];

    if (view === 'ontology' && field === 'FeaturedWork' && expected.toUpperCase() === 'FALSE') {
        const isFalse = rawValue === null || rawValue === undefined || rawValue === '' || String(rawValue).toUpperCase() === 'FALSE';
        return operator === 'IS' || operator === 'IS NOT' ? isFalse : false;
    }

    if (operator === 'IS') {
        return normalizedValues.some(value => value === expected);
    }
    if (operator === 'IS NOT') {
        if (metadataFields.includes(field) && view === 'ontology') {
            return normalizedValues.every(value => value !== expected);
        }
        return rawValue !== null && rawValue !== undefined && normalizedValues.every(value => value !== expected);
    }
    if (operator === 'CONTAINS') {
        return normalizedValues.some(value => value.toLowerCase().includes(expected.toLowerCase()));
    }
    if (operator === 'STARTS WITH') {
        return normalizedValues.some(value => value.toLowerCase().startsWith(expected.toLowerCase()));
    }
    if (operator === 'ENDS WITH') {
        return normalizedValues.some(value => value.toLowerCase().endsWith(expected.toLowerCase()));
    }
    if (['GREATER THAN', 'LESS THAN'].includes(operator)) {
        const actual = Number(rawValue);
        const target = Number(expected);
        if (!Number.isFinite(actual) || !Number.isFinite(target)) return false;
        return operator === 'GREATER THAN' ? actual > target : actual < target;
    }
    if (['PUBLISHED ON', 'UPDATED ON'].includes(operator)) {
        return normalizedValues.some(value => value === expected);
    }
    if (['PUBLISHED BEFORE', 'UPDATED BEFORE'].includes(operator)) {
        return normalizedValues.some(value => value <= expected);
    }
    if (['PUBLISHED AFTER', 'UPDATED AFTER'].includes(operator)) {
        return normalizedValues.some(value => value >= expected);
    }
    return false;
}

function filterByConditions(rows, conditions) {
    return rows.filter(record => {
        if (conditions.length === 0) return true;
        let result = conditionMatches(record, conditions[0]);
        for (let index = 1; index < conditions.length; index += 1) {
            const matches = conditionMatches(record, conditions[index]);
            result = conditions[index].logic === 'OR' ? result || matches : result && matches;
        }
        return result;
    });
}

// Query manager
// Gather unique options locally, filter the embedded catalogue, and update the table.
function toggleQueryBuilder(forceHide = false) {
    const queryBuilder = document.getElementById('queryBuilder');
    if (forceHide) {
        queryBuilder.classList.add('hidden');
    } else {
        queryBuilder.classList.toggle('hidden');
        if (!queryBuilder.classList.contains('hidden')) {
            const conditionsContainer = document.getElementById('conditionsContainer');
            if (conditionsContainer.children.length === 0) {
                addCondition();
            }
        }
    }
}

function toggleColumnSelector(forceHide = false) {
    const columnSelector = document.getElementById('columnSelector');
    if (forceHide) {
        columnSelector.classList.add('hidden');
    } else {
        columnSelector.classList.toggle('hidden');
    }
}

async function addCondition() {
    const container = document.getElementById('conditionsContainer');
    const conditionCount = container.children.length;
    if (conditionCount >= 5) {
        alert('You can add a maximum of 5 conditions.');
        return;
    }

    const config = getCurrentViewConfig();

    const conditionHTML = `
            <div class="query-condition">
                ${conditionCount > 0 ? `<div class="dropdown"><select class="logic-operator"><option>AND</option><option>OR</option></select><div class="dropdown-button"></div></div>` : ''}

                <div class="dropdown">
                    <select class="field-select" onchange="updateConditionInput(this)">
                        ${config.columns.map(col => {
        let displayName = col;
        if (col === 'SizeBytes') displayName = 'Size Bytes';
        else if (col === 'FeaturedWork') displayName = 'Featured';
        else if (col === 'PublishedDate') displayName = 'Published Date';
        else if (col === 'LastUpdated') displayName = 'Last Updated';
        else if (col === 'ReadingTimeMinutes') displayName = 'Reading Time';
        else if (col === 'WordCount') displayName = 'Word Count';
        else if (col !== 'UUID') displayName = col.replace(/([A-Z])/g, ' $1').trim();
        return `<option value="${col}">${displayName}</option>`;
    }).join('')}
                    </select>
                    <div class="dropdown-button"></div>
                </div>

                <div class="dropdown">
                    <select class="operator-select"></select>
                    <div class="dropdown-button"></div>
                </div>
                
                <span class="value-container"></span>

                ${conditionCount > 0 ? `<button class="button-table-settings query-remove" onclick="removeCondition(this)">×</button>` : ''}
            </div>`;

    container.insertAdjacentHTML('beforeend', conditionHTML);
    await updateConditionInput(container.lastElementChild.querySelector('.field-select'));
}

function removeCondition(button) {
    button.closest('.query-condition').remove();
}

async function updateConditionInput(selectElement) {
    const conditionDiv = selectElement.closest('.query-condition');
    const field = selectElement.value;
    const operatorSelect = conditionDiv.querySelector('.operator-select');
    const valueContainer = conditionDiv.querySelector('.value-container');

    let operators = getOperatorsForField(field);
    let inputHTML = `<input type="text" placeholder="Enter value..." class="value-input">`;

    switch (currentView) {
        case 'ontology':
            if (['Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords'].includes(field)) {
                try {
                    const values = await getDistinctValues(field);
                    inputHTML = `<div class="dropdown"><select class="value-select">${values.map(v => `<option>${v}</option>`).join('')}</select><div class="dropdown-button"></div></div>`;
                } catch (error) {
                    console.error('Error loading distinct values for ontology:', error);
                    inputHTML = `<input type="text" placeholder="Error loading options" class="value-input" disabled>`;
                }
            } else if (field === 'FeaturedWork') {
                inputHTML = `<div class="dropdown"><select class="value-select"><option>TRUE</option><option>FALSE</option></select><div class="dropdown-button"></div></div>`;
            } else if (field === 'Year') {
                inputHTML = `<input type="number" placeholder="Enter year..." class="value-input">`;
            }
            break;

        case 'fieldnotes':
            if (['PublishedDate', 'LastUpdated'].includes(field)) {
                inputHTML = `<input type="date" class="value-input">`;
            } else if (['ReadingTimeMinutes', 'WordCount'].includes(field)) {
                inputHTML = `<input type="number" min="0" step="1" placeholder="Enter number..." class="value-input">`;
            }
            break;

        // case 'album':
        //     if (field === 'Camera') {
        //         try {
        //             const values = await getDistinctValues(field);
        //             inputHTML = `<div class="dropdown"><select class="value-select">${values.map(v => `<option>${v}</option>`).join('')}</select><div class="dropdown-button"></div></div>`;
        //         } catch (error) {
        //             console.error('Error loading distinct values for album:', error);
        //             inputHTML = `<input type="text" placeholder="Error loading options" class="value-input" disabled>`;
        //         }
        //     } else if (['SizeBytes', 'Year'].includes(field)) {
        //         inputHTML = `<input type="number" placeholder="Enter number..." class="value-input">`;
        //     }
        //     break;
    }

    operatorSelect.innerHTML = operators.map(op => `<option value="${op}">${op}</option>`).join('');
    valueContainer.innerHTML = inputHTML;
}

async function getDistinctValues(field) {
    if (field === 'FeaturedWork') return ['TRUE', 'FALSE'];

    const values = getCatalogueRows().flatMap(record => getRecordValues(record, field));
    return [...new Set(values
        .filter(value => value !== null && value !== undefined && value !== '')
        .map(value => String(value)))]
        .sort((a, b) => a.localeCompare(b, undefined, { sensitivity: 'base', numeric: true }));
}

function getConditionsFromBuilder() {
    return Array.from(document.querySelectorAll('#conditionsContainer .query-condition')).map(cond => {
        const logic = cond.querySelector('.logic-operator')?.value || 'AND';
        const field = cond.querySelector('.field-select').value;
        const operator = cond.querySelector('.operator-select').value;
        const valueElement = cond.querySelector('.value-select, .value-input');
        const value = valueElement ? String(valueElement.value).trim() : '';
        return { logic, field, operator, value };
    });
}

function validateConditions(conditions, showAlerts = false) {
    if (conditions.length === 0) {
        if (showAlerts) alert('Please add at least one condition.');
        return false;
    }
    if (conditions.some(c => c.value === null || c.value === '')) {
        if (showAlerts) alert('Please ensure all conditions have a value.');
        return false;
    }
    return true;
}

function getUrlTokenFromOperator(operator) {
    return URL_OPERATOR_BY_QUERY_OPERATOR[operator] || '=';
}

function getOperatorFromUrlToken(token, field) {
    if (field === 'PublishedDate') {
        if (token === '=') return 'PUBLISHED ON';
        if (token === '<=') return 'PUBLISHED BEFORE';
        if (token === '>=') return 'PUBLISHED AFTER';
        return null;
    }
    if (field === 'LastUpdated') {
        if (token === '=') return 'UPDATED ON';
        if (token === '<=') return 'UPDATED BEFORE';
        if (token === '>=') return 'UPDATED AFTER';
        return null;
    }

    const mapping = {
        '=': 'IS',
        '!=': 'IS NOT',
        '~': 'CONTAINS',
        '*=': 'STARTS WITH',
        '$=': 'ENDS WITH',
        '>': 'GREATER THAN',
        '<': 'LESS THAN'
    };
    return mapping[token] || null;
}

function safeDecodeComponent(value) {
    try {
        return decodeURIComponent(value);
    } catch (error) {
        return value;
    }
}

function normalizeFieldForView(rawField, view) {
    const configColumns = view === 'fieldnotes' ? fieldnotesColumns : ontologyColumns;
    const normalizedField = String(rawField || '').replace(/\s+/g, '').toLowerCase();
    return configColumns.find(column => column.toLowerCase() === normalizedField) || null;
}

function serializeConditionsForUrl(conditions) {
    return conditions.map((condition, index) => {
        const logic = String(condition.logic || 'AND').toUpperCase() === 'OR' ? 'OR' : 'AND';
        const token = getUrlTokenFromOperator(condition.operator);
        const field = encodeURIComponent(condition.field);
        const value = encodeURIComponent(String(condition.value).trim());
        const logicPrefix = index > 0 ? `${logic}:` : '';
        return `${logicPrefix}${field}${token}${value}`;
    }).join(URL_QUERY_SEPARATOR);
}

function parseConditionSegment(segment, view, index) {
    let expression = segment.trim();
    let logic = 'AND';

    if (index > 0) {
        const upperSegment = expression.toUpperCase();
        if (upperSegment.startsWith('OR:')) {
            logic = 'OR';
            expression = expression.slice(3);
        } else if (upperSegment.startsWith('AND:')) {
            logic = 'AND';
            expression = expression.slice(4);
        }
    }

    let operatorMatch = null;
    for (const token of URL_OPERATOR_TOKENS) {
        const idx = expression.indexOf(token);
        if (idx > 0) {
            if (!operatorMatch || idx < operatorMatch.index || (idx === operatorMatch.index && token.length > operatorMatch.token.length)) {
                operatorMatch = { token, index: idx };
            }
        }
    }

    if (!operatorMatch) return null;

    const rawField = safeDecodeComponent(expression.slice(0, operatorMatch.index).trim());
    const rawValue = safeDecodeComponent(expression.slice(operatorMatch.index + operatorMatch.token.length).trim());
    if (!rawField || rawValue === '') return null;

    const field = normalizeFieldForView(rawField, view);
    if (!field) return null;

    const operator = getOperatorFromUrlToken(operatorMatch.token, field);
    if (!operator) return null;

    const validOperators = getOperatorsForField(field, view);
    if (!validOperators.includes(operator)) return null;

    return {
        logic,
        field,
        operator,
        value: rawValue
    };
}

function parseConditionsFromUrl(encodedQuery, view) {
    if (!encodedQuery) return [];

    return encodedQuery
        .split(URL_QUERY_SEPARATOR)
        .map((segment, index) => parseConditionSegment(segment, view, index))
        .filter(Boolean);
}

function updateQueryUrl(conditions = [], options = {}) {
    const { view = currentView, replaceHistory = false } = options;
    const url = new URL(window.location.href);
    url.searchParams.set(URL_VIEW_PARAM, normalizeView(view));

    if (conditions.length > 0) {
        url.searchParams.set(URL_QUERY_PARAM, serializeConditionsForUrl(conditions));
    } else {
        url.searchParams.delete(URL_QUERY_PARAM);
    }

    const nextUrl = `${url.pathname}${url.search}${url.hash}`;
    const currentUrl = `${window.location.pathname}${window.location.search}${window.location.hash}`;
    if (nextUrl === currentUrl) return;

    if (replaceHistory) {
        window.history.replaceState(null, '', nextUrl);
    } else {
        window.history.pushState(null, '', nextUrl);
    }
}

async function executeQuery(conditions, options = {}) {
    const { updateUrl = false, replaceHistory = false } = options;

    currentData = filterByConditions(getCatalogueRows(), conditions);
    sortData();
    renderTable(currentData);

    if (updateUrl) {
        updateQueryUrl(conditions, { replaceHistory });
    }
}

async function setQueryBuilderConditions(conditions) {
    const container = document.getElementById('conditionsContainer');
    container.innerHTML = '';

    for (let index = 0; index < conditions.length; index++) {
        const condition = conditions[index];
        await addCondition();
        const currentCondition = container.lastElementChild;
        const logicOperator = currentCondition.querySelector('.logic-operator');
        if (logicOperator) {
            logicOperator.value = condition.logic === 'OR' ? 'OR' : 'AND';
        }

        const fieldSelect = currentCondition.querySelector('.field-select');
        fieldSelect.value = condition.field;
        await updateConditionInput(fieldSelect);

        const operatorSelect = currentCondition.querySelector('.operator-select');
        if (Array.from(operatorSelect.options).some(option => option.value === condition.operator)) {
            operatorSelect.value = condition.operator;
        }

        const valueElement = currentCondition.querySelector('.value-select, .value-input');
        if (valueElement) {
            valueElement.value = condition.value;
        }
    }

    if (conditions.length > 0) {
        document.getElementById('queryBuilder').classList.remove('hidden');
    }
}

function readTableStateFromUrl() {
    const urlParams = new URLSearchParams(window.location.search);
    const view = normalizeView(urlParams.get(URL_VIEW_PARAM));
    const encodedQuery = urlParams.get(URL_QUERY_PARAM) || '';
    const conditions = parseConditionsFromUrl(encodedQuery, view);
    return { view, conditions };
}

function hasCustomColumnPrefs(view) {
    const defaults = defaultColumns[view] || [];
    const selected = columnPrefs[view] || defaults;
    return selected.length !== defaults.length || selected.some((column, index) => column !== defaults[index]);
}

async function initializeTableStateFromUrl() {
    const state = readTableStateFromUrl();
    switchView(state.view, { force: true, skipLoadData: true, skipUrlUpdate: true });

    if (state.conditions.length > 0) {
        await setQueryBuilderConditions(state.conditions);
        await executeQuery(state.conditions, { updateUrl: false });
    } else if (hasCustomColumnPrefs(state.view)) {
        await clearQuery({ skipUrlUpdate: true });
    } else {
        currentData = [...getCatalogueRows(state.view)];
        sortData();
        renderTable(currentData, { renderRows: false });
    }
}

async function runQuery() {
    const conditions = getConditionsFromBuilder();
    if (!validateConditions(conditions, true)) {
        return;
    }

    await executeQuery(conditions, { updateUrl: true });
}

async function clearQuery(options = {}) {
    const { skipLoadData = false, skipUrlUpdate = false, replaceHistory = false } = options;
    document.getElementById('conditionsContainer').innerHTML = '';
    toggleQueryBuilder(true);

    if (!skipLoadData) {
        await loadData();
    }
    if (!skipUrlUpdate) {
        updateQueryUrl([], { replaceHistory });
    }
}

// Static catalogue search
async function searchHandler() {
    const config = getCurrentViewConfig();
    const searchTerm = document.getElementById('searchInput').value;
    const tokens = searchTerm.trim().match(/[\p{L}\p{N}_-]+/gu) || [];
    const searchableRows = getCatalogueRows();

    if (tokens.length === 0) {
        currentData = [...searchableRows];
    } else {
        const normalizedTokens = tokens.map(token => token.toLocaleLowerCase());
        currentData = searchableRows.filter(record => {
            const searchableText = config.searchColumns
                .flatMap(field => getRecordValues(record, field))
                .filter(value => value !== null && value !== undefined)
                .join(' ')
                .toLocaleLowerCase();
            return normalizedTokens.every(token => searchableText.includes(token));
        });
    }

    sortData();
    renderTable(currentData);
}

function debounce(func, timeout = 300) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => { func.apply(this, args); }, timeout);
    };
}

if (typeof module !== 'undefined') {
    module.exports = { boundColumnResizeDelta };
}
