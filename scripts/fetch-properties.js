// Dynamically populate the properties field on all pages
document.addEventListener('DOMContentLoaded', function () {

    const detailsElement = document.getElementById('propertiesDetails');
    const contentElement = document.getElementById('properties-content');

    if (detailsElement && contentElement) {
        detailsElement.addEventListener('toggle', async function (event) {
            // Fetch
            if (event.target.open && !contentElement.hasAttribute('data-loaded')) {
                try {
                    const path = window.location.pathname;

                    let action = 'get_project_details';
                    if (path.includes('/fieldnotes/')) {
                        action = 'get_fieldnote_details';
                    }

                    // URL slug
                    const itemUrl = path.substring(path.lastIndexOf('/') + 1).replace('.html', '');

                    const response = await fetch(`../server.php?action=${action}&url=${itemUrl}`);

                    if (!response.ok) {
                        const errorData = await response.json().catch(() => ({ error: 'An unknown error occurred' }));
                        throw new Error(`Server responded with status ${response.status}: ${errorData.error}`);
                    }

                    const data = await response.json();

                    contentElement.innerHTML = '';
                    const pre = document.createElement('pre');
                    pre.className = 'secondary-text';
                    const code = document.createElement('code');
                    code.style.fontSize = '12px';
                    code.textContent = JSON.stringify(data, null, 2);
                    pre.appendChild(code);
                    contentElement.appendChild(pre);
                    contentElement.setAttribute('data-loaded', 'true');
                } catch (error) {
                    contentElement.innerHTML = `<p style="color: red;">Failed to load properties: ${error.message}</p>`;
                    console.error("Error fetching properties:", error);
                }
            }
        });
    }
});
