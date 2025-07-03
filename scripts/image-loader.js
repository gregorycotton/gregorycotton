// Load images on ontology pages using imageConfigurations variable

const imageCache = new Map();

async function fetchAndDisplayFileSizeInTable(imageUrl, cellId) {
    const cell = document.getElementById(cellId);
    if (!cell) return;
    try {
        const response = await fetch(imageUrl);
        if (!response.ok) {
            cell.textContent = 'Error';
            return;
        }
        const blob = await response.blob();
        cell.textContent = blob.size.toLocaleString();
    } catch (error) {
        cell.textContent = 'N/A';
    }
}

function displayImageFromBlob(imageBlob, imageTitle, displayElement) {
    const img = document.createElement('img');
    const objectURL = URL.createObjectURL(imageBlob);
    
    img.src = objectURL;
    img.alt = `${imageTitle} - Full size`;
    img.style.maxWidth = '100%';
    img.style.height = 'auto';
    img.style.display = 'block';
    // img.style.marginLeft = 'auto';
    // img.style.marginRight = 'auto';

    img.onload = () => {
        displayElement.innerHTML = '';
        displayElement.appendChild(img);
        displayElement.scrollIntoView({ behavior: 'smooth', block: 'start' });
        URL.revokeObjectURL(objectURL);
    };
    img.onerror = () => {
        URL.revokeObjectURL(objectURL);
        console.error(`Error loading image ${imageTitle} from blob.`);
        displayElement.innerHTML = `<p style="color: red;">Could not display cached image: ${imageTitle}.</p>`;
    };
}

async function loadAndDisplayFullImage(imageUrl, imageTitle, displayElement) {
    if (!displayElement) return;
    
    displayElement.innerHTML = '<p>Loading...</p>';
    displayElement.dataset.currentImageUrl = imageUrl;

    if (imageCache.has(imageUrl)) {
        const imageBlob = imageCache.get(imageUrl);
        displayImageFromBlob(imageBlob, imageTitle, displayElement);
        return;
    }

    try {
        const response = await fetch(imageUrl);
        if (!response.ok) throw new Error(`HTTP error! status: ${response.status}`);
        
        const imageBlob = await response.blob();
        
        imageCache.set(imageUrl, imageBlob);
        
        displayImageFromBlob(imageBlob, imageTitle, displayElement);

    } catch (error) {
        console.error(`Error fetching image "${imageTitle}":`, error);
        displayElement.innerHTML = `<p style="color: red;">Could not load image: ${imageTitle}. Error: ${error.message}</p>`;
    }
}

document.addEventListener('DOMContentLoaded', function () {
    if (typeof imageConfigurations !== 'undefined' && Array.isArray(imageConfigurations)) {
        imageConfigurations.forEach(config => {
            fetchAndDisplayFileSizeInTable(config.fullImageUrl, config.idForFileSizeCell);
        });
    }

    const interactiveTables = document.querySelectorAll('.image-loader-table');

    interactiveTables.forEach(table => {
        let activeTriggerElement = null;

        table.addEventListener('click', function (event) {
            const triggerElement = event.target.closest('.loadImageTrigger');

            if (triggerElement) {
                const fullImageUrl = triggerElement.dataset.fullimageurl;
                const imageTitle = triggerElement.dataset.title;
                const projResourceContainer = triggerElement.closest('.proj-resource-container');
                const displayArea = projResourceContainer.querySelector('.image-display-area');

                if (displayArea.dataset.currentImageUrl === fullImageUrl) {
                    return;
                }

                if (activeTriggerElement) {
                    const prevLink = activeTriggerElement.querySelector('a');
                    const prevUrl = activeTriggerElement.dataset.fullimageurl;
                    prevLink.textContent = prevUrl.endsWith('.gif') ? 'Load GIF' : 'Load image';
                }

                loadAndDisplayFullImage(fullImageUrl, imageTitle, displayArea);

                triggerElement.querySelector('a').textContent = 'Viewing';
                
                activeTriggerElement = triggerElement;
            }
        });
    });
});