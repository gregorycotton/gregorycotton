#!/usr/bin/env php
<?php
declare(strict_types=1);

const DEFAULT_WPM = 250;
const DEFAULT_DB_PATH = __DIR__ . '/../../database/projects.db';
const DEFAULT_FIELDNOTES_DIR = __DIR__ . '/../../fieldnotes';
const CONTENT_CLASS = 'proj-txt-container';

main($argv);

function main(array $argv): void
{
    $config = parseArguments($argv);

    if ($config['wpm'] <= 0) {
        fail('`--wpm` must be greater than 0.');
    }

    $db = openDatabase($config['db']);
    $fieldnotes = fetchFieldnotes($db, $config['all'], $config['target']);

    if (empty($fieldnotes)) {
        $message = $config['all']
            ? 'No fieldnotes rows found.'
            : sprintf('No fieldnote matched `%s`.', (string) $config['target']);
        fail($message);
    }

    if ($config['write']) {
        ensureFieldnoteStatsColumnsExist($db);
    }

    $results = [];
    foreach ($fieldnotes as $fieldnote) {
        $filePath = buildFieldnotePath($config['fieldnotesDir'], $fieldnote['URL']);
        $text = extractFieldnoteText($filePath);
        $wordCount = countWords($text);
        $readingTimeMinutes = $wordCount > 0 ? (int) ceil($wordCount / $config['wpm']) : 0;

        $results[] = [
            'uuid' => $fieldnote['UUID'],
            'title' => $fieldnote['Title'],
            'url' => $fieldnote['URL'],
            'filePath' => $filePath,
            'wordCount' => $wordCount,
            'readingTimeMinutes' => $readingTimeMinutes,
        ];
    }

    if ($config['write']) {
        writeResults($db, $results);
        echo "Updated SQLite rows.\n";
    } else {
        echo "Dry run only. No database changes were made.\n";
    }

    foreach ($results as $result) {
        printf(
            "%s | %s | %d words | %d min\n",
            $result['url'],
            $result['title'],
            $result['wordCount'],
            $result['readingTimeMinutes']
        );
    }
}

function parseArguments(array $argv): array
{
    $config = [
        'all' => false,
        'write' => false,
        'wpm' => DEFAULT_WPM,
        'db' => DEFAULT_DB_PATH,
        'fieldnotesDir' => DEFAULT_FIELDNOTES_DIR,
        'target' => null,
    ];

    $targets = [];
    foreach (array_slice($argv, 1) as $arg) {
        if ($arg === '--all') {
            $config['all'] = true;
            continue;
        }
        if ($arg === '--write') {
            $config['write'] = true;
            continue;
        }
        if ($arg === '--help' || $arg === '-h') {
            printUsage();
            exit(0);
        }
        if (str_starts_with($arg, '--wpm=')) {
            $config['wpm'] = (int) substr($arg, strlen('--wpm='));
            continue;
        }
        if (str_starts_with($arg, '--db=')) {
            $config['db'] = substr($arg, strlen('--db='));
            continue;
        }
        if (str_starts_with($arg, '--fieldnotes-dir=')) {
            $config['fieldnotesDir'] = substr($arg, strlen('--fieldnotes-dir='));
            continue;
        }
        if (str_starts_with($arg, '--')) {
            fail(sprintf('Unknown option `%s`.', $arg));
        }

        $targets[] = $arg;
    }

    if ($config['all'] && !empty($targets)) {
        fail('Use either `--all` or a single target, not both.');
    }

    if (!$config['all']) {
        if (count($targets) !== 1) {
            printUsage();
            exit(1);
        }
        $config['target'] = $targets[0];
    }

    return $config;
}

function printUsage(): void
{
    $usage = <<<TXT
Usage:
  php scripts/admin/update-fieldnote-stats.php <url-slug-or-uuid>
  php scripts/admin/update-fieldnote-stats.php --all

Options:
  --write                 Update SQLite rows instead of dry-run output.
  --wpm=250               Words per minute used for reading-time calculation.
  --db=/path/to/db        Override the SQLite database path.
  --fieldnotes-dir=/path  Override the fieldnotes HTML directory.
  --help, -h              Show this help text.

Notes:
  - Dry run is the default.
  - `--write` expects `fieldnotes.WordCount` and
    `fieldnotes.ReadingTimeMinutes` to already exist.
TXT;

    echo $usage . "\n";
}

function openDatabase(string $dbPath): PDO
{
    if (!is_file($dbPath)) {
        fail(sprintf('SQLite database not found at `%s`.', $dbPath));
    }

    $db = new PDO('sqlite:' . $dbPath);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    return $db;
}

function fetchFieldnotes(PDO $db, bool $all, ?string $target): array
{
    if ($all) {
        $stmt = $db->query("
            SELECT UUID, Title, URL
            FROM fieldnotes
            ORDER BY PublishedDate DESC, Title ASC
        ");
        return $stmt->fetchAll();
    }

    $stmt = $db->prepare("
        SELECT UUID, Title, URL
        FROM fieldnotes
        WHERE UUID = :target OR URL = :target
        ORDER BY Title ASC
    ");
    $stmt->execute([':target' => $target]);
    return $stmt->fetchAll();
}

function ensureFieldnoteStatsColumnsExist(PDO $db): void
{
    $columns = [];
    $stmt = $db->query("PRAGMA table_info(fieldnotes)");
    foreach ($stmt->fetchAll() as $column) {
        $columns[] = $column['name'];
    }

    $required = ['WordCount', 'ReadingTimeMinutes'];
    $missing = array_values(array_diff($required, $columns));
    if (!empty($missing)) {
        $sql = [
            'ALTER TABLE fieldnotes ADD COLUMN WordCount INTEGER;',
            'ALTER TABLE fieldnotes ADD COLUMN ReadingTimeMinutes INTEGER;',
        ];

        fail(
            "Cannot use `--write` yet because the `fieldnotes` table is missing: " .
            implode(', ', $missing) .
            "\nAdd the columns first, for example:\n" .
            implode("\n", $sql)
        );
    }
}

function buildFieldnotePath(string $fieldnotesDir, string $url): string
{
    return rtrim($fieldnotesDir, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR . $url . '.html';
}

function extractFieldnoteText(string $filePath): string
{
    if (!is_file($filePath) || !is_readable($filePath)) {
        fail(sprintf('Fieldnote HTML file not found or unreadable: `%s`.', $filePath));
    }

    $html = file_get_contents($filePath);
    if ($html === false) {
        fail(sprintf('Failed to read `%s`.', $filePath));
    }

    libxml_use_internal_errors(true);
    $dom = new DOMDocument();
    $loaded = $dom->loadHTML('<?xml encoding="utf-8" ?>' . $html, LIBXML_NONET | LIBXML_NOERROR | LIBXML_NOWARNING);
    $errors = libxml_get_errors();
    libxml_clear_errors();

    if ($loaded === false) {
        fail(sprintf('Failed to parse HTML in `%s`.', $filePath));
    }

    if (!empty($errors)) {
        // Parsing warnings are common with HTML documents; continue as long as loadHTML succeeded.
    }

    $xpath = new DOMXPath($dom);
    $nodes = $xpath->query(sprintf(
        "//*[contains(concat(' ', normalize-space(@class), ' '), ' %s ')]",
        CONTENT_CLASS
    ));

    if ($nodes === false || $nodes->length === 0) {
        fail(sprintf('No `%s` container found in `%s`.', CONTENT_CLASS, $filePath));
    }

    $textParts = [];
    foreach ($nodes as $node) {
        $textParts[] = $node->textContent;
    }

    return normalizeWhitespace(implode(' ', $textParts));
}

function normalizeWhitespace(string $text): string
{
    $text = preg_replace('/[\x{00A0}\x{1680}\x{2000}-\x{200A}\x{202F}\x{205F}\x{3000}]/u', ' ', $text) ?? $text;
    $text = preg_replace('/\s+/u', ' ', $text) ?? $text;
    return trim($text);
}

function countWords(string $text): int
{
    if ($text === '') {
        return 0;
    }

    preg_match_all("/[\p{L}\p{N}]+(?:['’\-][\p{L}\p{N}]+)*/u", $text, $matches);
    return count($matches[0]);
}

function writeResults(PDO $db, array $results): void
{
    $stmt = $db->prepare("
        UPDATE fieldnotes
        SET WordCount = :wordCount,
            ReadingTimeMinutes = :readingTimeMinutes
        WHERE UUID = :uuid
    ");

    $db->beginTransaction();
    try {
        foreach ($results as $result) {
            $stmt->execute([
                ':wordCount' => $result['wordCount'],
                ':readingTimeMinutes' => $result['readingTimeMinutes'],
                ':uuid' => $result['uuid'],
            ]);
        }
        $db->commit();
    } catch (Throwable $throwable) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $throwable;
    }
}

function fail(string $message): void
{
    fwrite(STDERR, $message . "\n");
    exit(1);
}
