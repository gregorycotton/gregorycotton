// Albums table image popup functionality

function showImagePopup(fileName) {
    const overlay = document.getElementById('imageOverlay');
    const img = document.getElementById('popupImage');
    const imageUrl = `/album/${fileName}.jpg`;

    img.src = imageUrl;
    img.onload = () => {
        overlay.classList.remove('hidden');
        img.classList.remove('hidden');
        document.addEventListener('keydown', handleEscapeKey);
    };
    img.onerror = () => {
        console.error(`Could not load image: ${imageUrl}`);
        alert(`Image not found: ${fileName}.jpg`);
        hideImagePopup();
    };
}

function hideImagePopup() {
    document.getElementById('imageOverlay').classList.add('hidden');
    document.getElementById('popupImage').classList.add('hidden');
    document.removeEventListener('keydown', handleEscapeKey);
}

function handleEscapeKey(event) {
    if (event.key === 'Escape') {
        hideImagePopup();
    }
}