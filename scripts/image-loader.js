// Image-table display modes and single-image viewers for generated resource blocks.

(function () {
    'use strict';

    function navigationIndex(index, offset, length) {
        const candidate = index + offset;
        return candidate >= 0 && candidate < length ? candidate : -1;
    }

    function isCurrentRequest(request, currentRequest) {
        return request === currentRequest;
    }

    if (typeof module === 'object' && module.exports) {
        module.exports = {isCurrentRequest, navigationIndex};
    }

    if (typeof document === 'undefined') return;

    const reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');

    function scrollTo(element, block = 'start') {
        element.scrollIntoView({
            behavior: reducedMotion.matches ? 'auto' : 'smooth',
            block,
        });
    }

    function setupImageBlock(block) {
        if (block.dataset.imageViewerReady === 'true') return;

        const tableContainer = block.querySelector('.table-container');
        const table = block.querySelector('.resource-table--image');
        const viewer = block.querySelector('.image-viewer');
        const header = viewer?.querySelector('.image-viewer-header');
        const viewerTitle = viewer?.querySelector('.image-viewer-title');
        const status = viewer?.querySelector('.image-viewer-status');
        const media = viewer?.querySelector('.image-viewer-media');
        const tableMode = block.querySelector('.image-table-mode');
        const contactMode = block.querySelector('.image-contact-mode');
        const previous = viewer?.querySelector('.image-viewer-previous');
        const count = viewer?.querySelector('.image-viewer-count');
        const next = viewer?.querySelector('.image-viewer-next');
        const back = viewer?.querySelector('.image-viewer-back');
        const open = viewer?.querySelector('.image-viewer-open');
        if (!tableContainer || !table || !viewer || !header || !viewerTitle || !status ||
            !media || !tableMode || !contactMode || !previous || !count || !next ||
            !back || !open) return;

        const items = Array.from(table.querySelectorAll('tbody .loadImageTrigger[data-fullimageurl]'))
            .map(trigger => {
                const row = trigger.closest('tr');
                const action = trigger.querySelector('.image-load-button');
                if (!row || !action) return null;
                const url = trigger.dataset.fullimageurl;
                const title = trigger.dataset.title || row.cells[1]?.textContent.trim() || 'Image';
                return {
                    action,
                    defaultLabel: action.textContent.trim(),
                    row,
                    title,
                    url,
                };
            })
            .filter(Boolean);
        if (!items.length) return;

        block.dataset.imageViewerReady = 'true';
        let activeIndex = -1;
        let loadSequence = 0;

        function setView(mode) {
            const contactSheet = mode === 'contact';
            table.classList.toggle('is-contact-sheet', contactSheet);
            tableContainer.classList.toggle('is-contact-sheet', contactSheet);
            tableMode.disabled = !contactSheet;
            contactMode.disabled = contactSheet;
            tableMode.setAttribute('aria-pressed', String(!contactSheet));
            contactMode.setAttribute('aria-pressed', String(contactSheet));
        }

        function updateSelection(index) {
            items.forEach((item, itemIndex) => {
                const selected = itemIndex === index;
                item.action.textContent = selected ? 'Viewing' : item.defaultLabel;
                item.action.setAttribute(
                    'aria-label',
                    selected ? `Viewing: ${item.title}` : `${item.defaultLabel}: ${item.title}`,
                );
                if (selected) item.action.setAttribute('aria-current', 'true');
                else item.action.removeAttribute('aria-current');
                item.row.classList.toggle('is-viewing', selected);
            });
        }

        function updateViewer(index) {
            const item = items[index];
            viewerTitle.textContent = item.title;
            count.textContent = `${index + 1} of ${items.length}`;
            previous.disabled = navigationIndex(index, -1, items.length) < 0;
            next.disabled = navigationIndex(index, 1, items.length) < 0;
            open.href = item.url;
        }

        function restoreHeaderPosition(top) {
            if (top === null) return;
            requestAnimationFrame(() => {
                window.scrollBy(0, header.getBoundingClientRect().top - top);
            });
        }

        function displayImage(index, scrollViewer) {
            if (index < 0 || index >= items.length) return;
            if (index === activeIndex) {
                if (scrollViewer) {
                    scrollTo(header);
                    header.focus({preventScroll: true});
                }
                return;
            }

            const item = items[index];
            const request = ++loadSequence;
            const preservedHeaderTop = scrollViewer ? null : header.getBoundingClientRect().top;
            const currentMediaHeight = media.offsetHeight;
            if (currentMediaHeight) media.style.minHeight = `${currentMediaHeight}px`;

            activeIndex = index;
            updateSelection(index);
            updateViewer(index);
            viewer.hidden = false;
            viewer.classList.add('is-loading');
            status.textContent = 'Loading…';
            media.replaceChildren();

            if (scrollViewer) {
                requestAnimationFrame(() => {
                    scrollTo(header);
                    header.focus({preventScroll: true});
                });
            }

            const image = new Image();
            image.alt = `${item.title} - Full size`;
            image.onload = function () {
                if (!isCurrentRequest(request, loadSequence)) return;
                media.replaceChildren(image);
                media.style.minHeight = '';
                viewer.classList.remove('is-loading');
                status.textContent = '';
                restoreHeaderPosition(preservedHeaderTop);
            };
            image.onerror = function () {
                if (!isCurrentRequest(request, loadSequence)) return;
                media.replaceChildren();
                media.style.minHeight = '';
                viewer.classList.remove('is-loading');
                status.textContent = `Could not load image: ${item.title}.`;
                restoreHeaderPosition(preservedHeaderTop);
            };
            image.src = item.url;
        }

        items.forEach((item, index) => {
            item.action.addEventListener('click', () => displayImage(index, true));
        });
        tableMode.addEventListener('click', () => setView('table'));
        contactMode.addEventListener('click', () => setView('contact'));
        previous.addEventListener('click', () => {
            displayImage(navigationIndex(activeIndex, -1, items.length), false);
        });
        next.addEventListener('click', () => {
            displayImage(navigationIndex(activeIndex, 1, items.length), false);
        });
        back.addEventListener('click', () => {
            if (activeIndex < 0) return;
            const selected = items[activeIndex];
            scrollTo(selected.row, 'center');
            selected.action.focus({preventScroll: true});
        });
        viewer.addEventListener('keydown', event => {
            if (event.altKey || event.ctrlKey || event.metaKey || event.shiftKey) return;
            const offset = event.key === 'ArrowLeft' ? -1 : event.key === 'ArrowRight' ? 1 : 0;
            if (!offset) return;
            const target = navigationIndex(activeIndex, offset, items.length);
            if (target < 0) return;
            event.preventDefault();
            displayImage(target, false);
        });

        setView('table');
    }

    function initializeImageViewers() {
        document.querySelectorAll('.image-resource-block').forEach(setupImageBlock);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initializeImageViewers, {once: true});
    } else {
        initializeImageViewers();
    }
}());
