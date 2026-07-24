// Initialization
// Set initial state and load the embedded static catalogue on page load

document.addEventListener('DOMContentLoaded', async () => {
    document.getElementById('searchInput').addEventListener('input', debounce(searchHandler, 300));
    loadEmbeddedCatalogue();
    await initializeTableStateFromUrl();
    window.addEventListener('popstate', () => {
        initializeTableStateFromUrl();
    });
});

function loadEmbeddedCatalogue() {
    const dataElement = document.getElementById('catalogue-data');
    if (!dataElement) {
        console.error('Embedded catalogue data was not found on the homepage. Run the catalogue build first.');
        alert('Static catalogue data was not found. Run the catalogue build before deploying.');
        catalogueData = { views: { ontology: { rows: [] }, fieldnotes: { rows: [] } } };
        return;
    }

    try {
        const parsedData = JSON.parse(dataElement.textContent || '{}');
        if (!parsedData.views?.ontology || !parsedData.views?.fieldnotes) {
            throw new Error('Embedded catalogue is missing a required view.');
        }
        catalogueData = parsedData;
    } catch (error) {
        console.error('Failed to load embedded catalogue:', error);
        alert('Failed to load the static catalogue. Run the catalogue build before deploying.');
        catalogueData = { views: { ontology: { rows: [] }, fieldnotes: { rows: [] } } };
    }
}

async function loadData() {
    const config = getCurrentViewConfig();
    currentColumns = columnPrefs[currentView];

    const viewData = catalogueData?.views?.[currentView]?.rows;
    if (!Array.isArray(viewData)) {
        console.error(`Static catalogue data not found for view: ${currentView}`);
        currentData = [];
    } else {
        currentData = [...viewData];
    }

    if (!config.columns.includes(sortColumn)) {
        sortColumn = config.defaultSort;
        sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated'].includes(sortColumn) ? 'desc' : 'asc';
    }
    sortData();
    renderTable(currentData);
    setupColumnSelectors();
}
