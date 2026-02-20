// Initialization
// Set initial state, fetch data from server on page load

document.addEventListener('DOMContentLoaded', async () => {
    document.getElementById('searchInput').addEventListener('input', debounce(searchHandler, 300));
    await initializeTableStateFromUrl();
    window.addEventListener('popstate', () => {
        initializeTableStateFromUrl();
    });
});

async function loadData() {
    const config = getCurrentViewConfig();
    currentColumns = columnPrefs[currentView];

    try {
        const response = await fetch(`server.php?action=get_${config.apiBaseAction}`);
        const data = await response.json();
        if (data.error) {
            console.error('Server Error:', data.error);
            alert(`Error loading data: ${data.error}`);
            currentData = [];
        } else {
            currentData = data;
        }
        if (!config.columns.includes(sortColumn)) {
            sortColumn = config.defaultSort;
            sortDirection = ['Year', 'SizeBytes', 'PublishedDate', 'LastUpdated'].includes(sortColumn) ? 'desc' : 'asc';
        }
        sortData();
        renderTable(currentData);
        setupColumnSelectors();
    } catch (error) {
        console.error('Fetch Error:', error);
        alert('Failed to fetch data from the server.');
        currentData = [];
        renderTable(currentData);
    }
}
