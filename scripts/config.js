// Global config, state variables, local storage management
// Establish foundational settings and state for the application

const ontologyColumns = ['UUID', 'Title', 'ShortDescription', 'Year',
    'Modality', 'Medium', 'Tools', 'Object',
    'Collaborators', 'Keywords', 'FeaturedWork'];
const fieldnotesColumns = ['UUID', 'Title', 'ShortDescription', 'PublishedDate', 'LastUpdated'];
const albumColumns = ['UUID', 'FileName', 'ShortDescription', 'Camera', 'SizeBytes', 'Year'];

const defaultColumns = {
    ontology: ['Title', 'ShortDescription', 'Year', 'Object'],
    fieldnotes: ['Title', 'ShortDescription', 'PublishedDate', 'LastUpdated'],
    album: ['FileName', 'ShortDescription', 'Camera', 'Year']
};

const storageKey = 'gregoryCottonColumnPrefs_v2';
let columnPrefs = loadColumnPrefs();

let currentView = 'ontology';
let currentColumns = columnPrefs[currentView];
let currentData = [];
let sortColumn = 'Year';
let sortDirection = 'desc';

// Read/write for browser localStorage 
// User column selections remembered across sessions
function loadColumnPrefs() {
    let prefs = { ...defaultColumns };
    try {
        const storedPrefs = localStorage.getItem(storageKey);
        if (storedPrefs) {
            const parsedPrefs = JSON.parse(storedPrefs);
            if (parsedPrefs.ontology && Array.isArray(parsedPrefs.ontology)) {
                prefs.ontology = parsedPrefs.ontology.filter(col => ontologyColumns.includes(col));
                if (prefs.ontology.length === 0) prefs.ontology = defaultColumns.ontology;
            }
            if (parsedPrefs.fieldnotes && Array.isArray(parsedPrefs.fieldnotes)) {
                prefs.fieldnotes = parsedPrefs.fieldnotes.filter(col => fieldnotesColumns.includes(col));
                if (prefs.fieldnotes.length === 0) prefs.fieldnotes = defaultColumns.fieldnotes;
            }
            if (parsedPrefs.album && Array.isArray(parsedPrefs.album)) {
                prefs.album = parsedPrefs.album.filter(col => albumColumns.includes(col));
                if (prefs.album.length === 0) prefs.album = defaultColumns.album;
            }
        }
    } catch (error) {
        console.error('Error parsing column preferences from localStorage:', error);
        prefs = { ...defaultColumns };
    }
    if (!prefs.ontology) prefs.ontology = defaultColumns.ontology;
    if (!prefs.fieldnotes) prefs.fieldnotes = defaultColumns.fieldnotes;
    if (!prefs.album) prefs.album = defaultColumns.album;

    return prefs;
}

function saveColumnPrefs() {
    try {
        columnPrefs[currentView] = currentColumns;
        localStorage.setItem(storageKey, JSON.stringify(columnPrefs));
    } catch (error) {
        console.error('Error saving column preferences to localStorage:', error);
    }
}