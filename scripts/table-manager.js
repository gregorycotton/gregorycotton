// Responsible for all DOM manipulation related to rendering the data table and handling data sorting logic.

function renderTable(data) {
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
        } else if (col !== 'UUID') {
            displayName = col.replace(/([A-Z])/g, ' $1').trim();
        }
        return `<th class="sort-th">${displayName}${arrow}</th>`;
    }).join('');

    thead.querySelectorAll('th').forEach((th, index) => {
        const column = orderedColumns[index];
        th.addEventListener('click', () => {
            if (sortColumn === column) {
                sortDirection = sortDirection === 'asc' ? 'desc' : 'asc';
            } else {
                sortColumn = column;
                sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated'].includes(column) ? 'desc' : 'asc';
            }
            sortData();
            renderTable(currentData);
        });
    });

    tbody.innerHTML = data.map(item => {
        const rowContent = orderedColumns.map(col => {
            let value = item[col] ?? 'N/A';

            if (currentView === 'ontology') {
                if (col === 'Title' && item.URL) {
                    value = `<a class="table-link" href="/ontology/${item.URL}.html">${item[col]}</a>`;
                } else if (['Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords'].includes(col)) {
                    value = item[col] ? item[col].split(',').map(v => v.trim()).join(', ') : 'N/A';
                } else if (col === 'FeaturedWork') {
                    value = item[col] === 'TRUE' ? 'TRUE' : 'FALSE';
                }
            } else if (currentView === 'fieldnotes') {
                if (col === 'Title' && item.URL) {
                    value = `<a class="table-link" href="/fieldnotes/${item.URL}.html">${item[col]}</a>`;
                } else if (['PublishedDate', 'LastUpdated'].includes(col) && value !== 'N/A') {
                    try {
                        const [year, month, day] = value.split('-');
                        if (year && month && day) {
                            value = `${day}/${month}/${year}`;
                        }
                    } catch (e) { /* Ignore formatting error */ }
                }
            // } else if (currentView === 'album') {
            //     if (col === 'SizeBytes' && value !== 'N/A') {
            //         value = Number(value).toLocaleString();
            //     } else if (col === 'FileName' && value !== 'N/A') {
            //         const fileName = item[col];
            //         value = `<a class="table-link" href="#" onclick="showImagePopup('${fileName}'); return false;">${fileName}</a>`;
            //     }
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
        sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated'].includes(sortColumn) ? 'desc' : 'asc';
    }

    currentData.sort((a, b) => {
        let valA = a[sortColumn];
        let valB = b[sortColumn];

        if (['Year', 'SizeBytes'].includes(sortColumn)) {
            valA = parseInt(valA, 10) || 0;
            valB = parseInt(valB, 10) || 0;
        } else if (['PublishedDate', 'LastUpdated'].includes(sortColumn)) {
            valA = valA ?? '';
            valB = valB ?? '';
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
                defaultSort: 'Year'
            };
        case 'fieldnotes':
            return {
                columns: fieldnotesColumns,
                tableId: 'fieldnotesTable',
                viewId: 'fieldnotesView',
                apiBaseAction: 'fieldnotes',
                titleField: 'Title',
                defaultSort: 'PublishedDate'
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
                defaultSort: 'Year'
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
    sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated'].includes(sortColumn) ? 'desc' : 'asc';
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
                'LastUpdated': ['UPDATED ON', 'UPDATED BEFORE', 'UPDATED AFTER']
            };
        default:
            return {};
    }
}

function getOperatorsForField(field, view = currentView) {
    const map = getOperatorMapForView(view);
    return map[field] || ['IS', 'CONTAINS'];
}

// Query manager
// Fetch unique options from the server, gather user selections, construct query string, fetch filtered data from server, update table
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
    const config = getCurrentViewConfig();
    try {
        const response = await fetch(`server.php?action=get_distinct_${config.apiBaseAction}&field=${field}`);
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return await response.json();
    } catch (error) {
        console.error(`Failed to fetch distinct values for ${field} in view ${currentView}:`, error);
        return [];
    }
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
    const config = getCurrentViewConfig();
    const queryParams = new URLSearchParams();
    queryParams.append('action', `query_${config.apiBaseAction}`);
    conditions.forEach((cond, index) => {
        queryParams.append(`conditions[${index}][logic]`, cond.logic);
        queryParams.append(`conditions[${index}][field]`, cond.field);
        queryParams.append(`conditions[${index}][operator]`, cond.operator);
        queryParams.append(`conditions[${index}][value]`, cond.value);
    });

    try {
        const response = await fetch(`server.php?${queryParams.toString()}`);
        const data = await response.json();
        if (data.error) {
            console.error('Server Error:', data.error);
            alert(`Error running query: ${data.error}`);
            currentData = [];
        } else {
            currentData = data;
        }
        sortData();
        renderTable(currentData);

        if (updateUrl) {
            updateQueryUrl(conditions, { replaceHistory });
        }
    } catch (error) {
        console.error('Fetch Error:', error);
        alert('Failed to fetch query results from the server.');
        currentData = [];
        renderTable(currentData);
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

async function initializeTableStateFromUrl() {
    const state = readTableStateFromUrl();
    switchView(state.view, { force: true, skipLoadData: true, skipUrlUpdate: true });

    if (state.conditions.length > 0) {
        await setQueryBuilderConditions(state.conditions);
        await executeQuery(state.conditions, { updateUrl: false });
    } else {
        await clearQuery({ skipUrlUpdate: true });
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

// Database search
// TODO: FTS5 for database search
async function searchHandler() {
    const config = getCurrentViewConfig();
    const searchTerm = document.getElementById('searchInput').value;

    try {
        const response = await fetch(`server.php?action=search_${config.apiBaseAction}&term=${encodeURIComponent(searchTerm)}`);
        const data = await response.json();
        if (data.error) {
            console.error('Server Error:', data.error);
            alert(`Error during search: ${data.error}`);
            currentData = [];
        } else {
            currentData = data;
        }
        sortData();
        renderTable(currentData);
    } catch (error) {
        console.error('Search Fetch Error:', error);
        alert('Failed to fetch search results from the server.');
        currentData = [];
        renderTable(currentData);
    }
}

function debounce(func, timeout = 300) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => { func.apply(this, args); }, timeout);
    };
}
