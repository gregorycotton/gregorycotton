<?php
// Rate limiting logic
session_start();

define('RATE_LIMIT_SECONDS', 60);
define('RATE_LIMIT_REQUESTS', 100);

if (!isset($_SESSION['request_timestamps'])) {
    $_SESSION['request_timestamps'] = [];
}

$currentTime = time();

$_SESSION['request_timestamps'] = array_filter($_SESSION['request_timestamps'], function ($timestamp) use ($currentTime) {
    return ($currentTime - $timestamp) < RATE_LIMIT_SECONDS;
});

if (count($_SESSION['request_timestamps']) >= RATE_LIMIT_REQUESTS) {
    http_response_code(429);
    header('Content-Type: application/json');
    echo json_encode(['error' => 'Too many requests. Please try again in a minute.']);
    exit;
}

$_SESSION['request_timestamps'][] = $currentTime;

header('Access-Control-Allow-Origin: *');
header('Content-Type: application/json');

// Database Connection
try {
    //$db = new PDO('sqlite:/var/www/gregorycotton.ca/database/projects.db');
    $db = new PDO('sqlite:database/projects.db');
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $db->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit;
}

$action = $_GET['action'] ?? '';

// Build Base Query for Projects
function getProjectsBaseQuery() {
    return "
        SELECT p.*,
        GROUP_CONCAT(DISTINCT m.Modality) AS Modality,
        GROUP_CONCAT(DISTINCT md.Medium) AS Medium,
        GROUP_CONCAT(DISTINCT t.Tool) AS Tools,
        GROUP_CONCAT(DISTINCT o.Object) AS Object,
        GROUP_CONCAT(DISTINCT c.Collaborator) AS Collaborators,
        GROUP_CONCAT(DISTINCT k.Keyword) AS Keywords
        FROM projects p
        LEFT JOIN modalities m ON p.UUID = m.UUID
        LEFT JOIN mediums md ON p.UUID = md.UUID
        LEFT JOIN tools t ON p.UUID = t.UUID
        LEFT JOIN objects o ON p.UUID = o.UUID
        LEFT JOIN collaborators c ON p.UUID = c.UUID
        LEFT JOIN keywords k ON p.UUID = k.UUID
    ";
}

// Build Base Query for Fieldnotes
function getFieldnotesBaseQuery() {
    return "SELECT fn.* FROM fieldnotes fn";
}

// Build Where Clauses and Params
function buildWhereClause($conditions, $viewType = 'ontology') {
    $params = [];
    $whereClauses = [];

    $ontologyTableMap = [
        'Modality' => ['table' => 'modalities', 'column' => 'Modality'],
        'Medium' => ['table' => 'mediums', 'column' => 'Medium'],
        'Tools' => ['table' => 'tools', 'column' => 'Tool'],
        'Object' => ['table' => 'objects', 'column' => 'Object'],
        'Collaborators' => ['table' => 'collaborators', 'column' => 'Collaborator'],
        'Keywords' => ['table' => 'keywords', 'column' => 'Keyword']
    ];

    $mainTableAlias = '';
    switch($viewType) {
        case 'ontology': $mainTableAlias = 'p'; break;
        case 'fieldnotes': $mainTableAlias = 'fn'; break;
        // case 'album': $mainTableAlias = 'a'; break;
        default: throw new Exception("Invalid view type specified: $viewType");
    }

    $validFields = [];
     switch($viewType) {
        case 'ontology': $validFields = ['UUID', 'Title', 'ShortDescription', 'Year', 'Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords', 'FeaturedWork']; break;
        case 'fieldnotes': $validFields = ['UUID', 'Title', 'ShortDescription', 'PublishedDate', 'LastUpdated']; break;
        // case 'album': $validFields = ['UUID', 'FileName', 'ShortDescription', 'Camera', 'SizeBytes', 'Year']; break;
     }

    foreach ($conditions as $index => $condition) {
        $field = $condition['field'] ?? null;
        $operator = strtoupper($condition['operator'] ?? 'IS');
        $value = $condition['value'] ?? null;
        $logic = ($index > 0) ? ($condition['logic'] ?? 'AND') : '';

        if ($field === null || !in_array($field, $validFields) || $value === null || $value === '') continue;

        $whereFragment = '';
        $paramValue = $value;

        if ($viewType === 'ontology' && isset($ontologyTableMap[$field])) {
             $tableInfo = $ontologyTableMap[$field];
             $subQueryOperator = ($operator === 'IS NOT') ? 'NOT IN' : 'IN';

             $whereFragment = "$logic $mainTableAlias.UUID $subQueryOperator (
                 SELECT UUID FROM {$tableInfo['table']} WHERE {$tableInfo['column']} = ?
             )";
              $params[] = $paramValue;
        }
        else {
            $columnRef = "$mainTableAlias.$field";

            switch($operator) {
                case 'CONTAINS':
                    $whereFragment = "$logic $columnRef LIKE ?";
                    $paramValue = "%$value%";
                    break;
                case 'STARTS WITH':
                    $whereFragment = "$logic $columnRef LIKE ?";
                    $paramValue = "$value%";
                    break;
                case 'ENDS WITH':
                    $whereFragment = "$logic $columnRef LIKE ?";
                    $paramValue = "%$value";
                    break;
                case 'GREATER THAN':
                     $whereFragment = "$logic $columnRef > ?";
                      if (($field === 'Year' || $field === 'SizeBytes') && !is_numeric($value)) {
                          throw new Exception("Value for GREATER THAN must be numeric for field $field.");
                      }
                     $paramValue = $value;
                     break;
                case 'LESS THAN':
                     $whereFragment = "$logic $columnRef < ?";
                      if (($field === 'Year' || $field === 'SizeBytes') && !is_numeric($value)) {
                         throw new Exception("Value for LESS THAN must be numeric for field $field.");
                      }
                     $paramValue = $value;
                    break;
                case 'PUBLISHED ON':
                case 'UPDATED ON':
                    $whereFragment = "$logic $columnRef = ?";
                    $paramValue = $value;
                    break;
                case 'PUBLISHED BEFORE':
                case 'UPDATED BEFORE':
                     $whereFragment = "$logic $columnRef <= ?";
                     $paramValue = $value;
                     break;
                case 'PUBLISHED AFTER':
                case 'UPDATED AFTER':
                     $whereFragment = "$logic $columnRef >= ?";
                     $paramValue = $value;
                     break;
                case 'IS NOT':
                    $whereFragment = "$logic $columnRef != ?";
                    $paramValue = $value;
                    if ($viewType === 'ontology' && $field === 'FeaturedWork' && strtoupper($value) === 'FALSE') {
                        $whereFragment = "$logic ($columnRef IS NULL OR $columnRef = ? OR $columnRef = '')";
                        $paramValue = 'FALSE';
                    } elseif (($field === 'Year' || $field === 'SizeBytes') && !is_numeric($value)) {
                         throw new Exception("Value for IS NOT must be numeric for field $field.");
                    }
                    break;
                case 'IS':
                default:
                    $whereFragment = "$logic $columnRef = ?";
                    $paramValue = $value;
                    if ($viewType === 'ontology' && $field === 'FeaturedWork' && strtoupper($value) === 'FALSE') {
                         $whereFragment = "$logic ($columnRef IS NULL OR $columnRef = ? OR $columnRef = '')";
                         $paramValue = 'FALSE';
                    } elseif (($field === 'Year' || $field === 'SizeBytes') && !is_numeric($value)) {
                         throw new Exception("Value for IS must be numeric for field $field.");
                    }
                    break;
            }
            $params[] = $paramValue;
        }

        if (!empty($whereFragment)) {
            $whereClauses[] = $whereFragment;
        }
    }

    $whereSql = '';
    if (!empty($whereClauses)) {
        $whereSql = "WHERE " . ltrim(implode(' ', $whereClauses));
    }

    return ['sql' => $whereSql, 'params' => $params];
}

function isFts5Available($db) {
    static $fts5Available = null;
    if ($fts5Available !== null) {
        return $fts5Available;
    }

    try {
        $db->exec("CREATE VIRTUAL TABLE IF NOT EXISTS __fts5_probe USING fts5(content)");
        $db->exec("DROP TABLE IF EXISTS __fts5_probe");
        $fts5Available = true;
    } catch (PDOException $e) {
        error_log("FTS5 unavailable: " . $e->getMessage());
        $fts5Available = false;
    }

    return $fts5Available;
}

function buildFtsMatchQuery($term) {
    $rawTerm = trim((string)$term);
    if ($rawTerm === '') {
        return '';
    }

    preg_match_all('/[\p{L}\p{N}_-]+/u', $rawTerm, $matches);
    $tokens = array_values(array_unique(array_filter($matches[0], function($token) {
        return $token !== '';
    })));

    if (empty($tokens)) {
        return '';
    }

    $ftsParts = [];
    foreach ($tokens as $token) {
        $escapedToken = str_replace('"', '""', $token);
        $ftsParts[] = '"' . $escapedToken . '"*';
    }

    return implode(' AND ', $ftsParts);
}

function ensureSearchIndexMetaAndTriggers($db) {
    $db->exec("
        CREATE TABLE IF NOT EXISTS search_index_meta (
            IndexName TEXT PRIMARY KEY,
            IsDirty INTEGER NOT NULL DEFAULT 1
        )
    ");

    $db->exec("INSERT OR IGNORE INTO search_index_meta (IndexName, IsDirty) VALUES ('projects', 1)");
    $db->exec("INSERT OR IGNORE INTO search_index_meta (IndexName, IsDirty) VALUES ('fieldnotes', 1)");

    $triggerDefinitions = [
        'projects' => ['projects', 'modalities', 'mediums', 'tools', 'objects', 'collaborators', 'keywords'],
        'fieldnotes' => ['fieldnotes']
    ];

    foreach ($triggerDefinitions as $indexName => $tables) {
        foreach ($tables as $tableName) {
            foreach (['INSERT', 'UPDATE', 'DELETE'] as $event) {
                $triggerName = "trg_{$tableName}_" . strtolower($event) . "_mark_{$indexName}_dirty";
                $db->exec("
                    CREATE TRIGGER IF NOT EXISTS $triggerName
                    AFTER $event ON $tableName
                    BEGIN
                        UPDATE search_index_meta
                        SET IsDirty = 1
                        WHERE IndexName = '$indexName';
                    END
                ");
            }
        }
    }
}

function ensureProjectsFtsTable($db) {
    $sqlStmt = $db->query("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'projects_fts'");
    $existingSql = $sqlStmt ? $sqlStmt->fetchColumn() : false;
    if ($sqlStmt) {
        $sqlStmt->closeCursor();
    }
    if (is_string($existingSql) && stripos($existingSql, 'UUID UNINDEXED') !== false) {
        $db->exec("DROP TABLE IF EXISTS projects_fts");
        $db->exec("UPDATE search_index_meta SET IsDirty = 1 WHERE IndexName = 'projects'");
    }

    $db->exec("
        CREATE VIRTUAL TABLE IF NOT EXISTS projects_fts USING fts5(
            UUID,
            Title,
            ShortDescription,
            Year,
            Modality,
            Medium,
            Tools,
            Object,
            Collaborators,
            Keywords,
            tokenize = 'unicode61 remove_diacritics 2'
        )
    ");
}

function ensureFieldnotesFtsTable($db) {
    $sqlStmt = $db->query("SELECT sql FROM sqlite_master WHERE type = 'table' AND name = 'fieldnotes_fts'");
    $existingSql = $sqlStmt ? $sqlStmt->fetchColumn() : false;
    if ($sqlStmt) {
        $sqlStmt->closeCursor();
    }
    if (is_string($existingSql) && stripos($existingSql, 'UUID UNINDEXED') !== false) {
        $db->exec("DROP TABLE IF EXISTS fieldnotes_fts");
        $db->exec("UPDATE search_index_meta SET IsDirty = 1 WHERE IndexName = 'fieldnotes'");
    }

    $db->exec("
        CREATE VIRTUAL TABLE IF NOT EXISTS fieldnotes_fts USING fts5(
            UUID,
            Title,
            ShortDescription,
            PublishedDate,
            LastUpdated,
            tokenize = 'unicode61 remove_diacritics 2'
        )
    ");
}

function rebuildProjectsFtsIndex($db) {
    $db->beginTransaction();
    try {
        $db->exec("DELETE FROM projects_fts");
        $db->exec("
            INSERT INTO projects_fts (
                UUID, Title, ShortDescription, Year,
                Modality, Medium, Tools, Object, Collaborators, Keywords
            )
            SELECT
                p.UUID,
                COALESCE(p.Title, ''),
                COALESCE(p.ShortDescription, ''),
                COALESCE(CAST(p.Year AS TEXT), ''),
                REPLACE(COALESCE(m.Modality, ''), ',', ' '),
                REPLACE(COALESCE(md.Medium, ''), ',', ' '),
                REPLACE(COALESCE(t.Tool, ''), ',', ' '),
                REPLACE(COALESCE(o.Object, ''), ',', ' '),
                REPLACE(COALESCE(c.Collaborator, ''), ',', ' '),
                REPLACE(COALESCE(k.Keyword, ''), ',', ' ')
            FROM projects p
            LEFT JOIN (
                SELECT UUID, GROUP_CONCAT(DISTINCT Modality) AS Modality
                FROM modalities
                GROUP BY UUID
            ) m ON m.UUID = p.UUID
            LEFT JOIN (
                SELECT UUID, GROUP_CONCAT(DISTINCT Medium) AS Medium
                FROM mediums
                GROUP BY UUID
            ) md ON md.UUID = p.UUID
            LEFT JOIN (
                SELECT UUID, GROUP_CONCAT(DISTINCT Tool) AS Tool
                FROM tools
                GROUP BY UUID
            ) t ON t.UUID = p.UUID
            LEFT JOIN (
                SELECT UUID, GROUP_CONCAT(DISTINCT Object) AS Object
                FROM objects
                GROUP BY UUID
            ) o ON o.UUID = p.UUID
            LEFT JOIN (
                SELECT UUID, GROUP_CONCAT(DISTINCT Collaborator) AS Collaborator
                FROM collaborators
                GROUP BY UUID
            ) c ON c.UUID = p.UUID
            LEFT JOIN (
                SELECT UUID, GROUP_CONCAT(DISTINCT Keyword) AS Keyword
                FROM keywords
                GROUP BY UUID
            ) k ON k.UUID = p.UUID
        ");
        $db->exec("UPDATE search_index_meta SET IsDirty = 0 WHERE IndexName = 'projects'");
        $db->commit();
    } catch (PDOException $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $e;
    }
}

function rebuildFieldnotesFtsIndex($db) {
    $db->beginTransaction();
    try {
        $db->exec("DELETE FROM fieldnotes_fts");
        $db->exec("
            INSERT INTO fieldnotes_fts (UUID, Title, ShortDescription, PublishedDate, LastUpdated)
            SELECT
                UUID,
                COALESCE(Title, ''),
                COALESCE(ShortDescription, ''),
                COALESCE(PublishedDate, ''),
                COALESCE(LastUpdated, '')
            FROM fieldnotes
        ");
        $db->exec("UPDATE search_index_meta SET IsDirty = 0 WHERE IndexName = 'fieldnotes'");
        $db->commit();
    } catch (PDOException $e) {
        if ($db->inTransaction()) {
            $db->rollBack();
        }
        throw $e;
    }
}

function ensureFtsSearchIndex($db, $indexName) {
    if (!isFts5Available($db)) {
        return false;
    }

    ensureSearchIndexMetaAndTriggers($db);

    if ($indexName === 'projects') {
        ensureProjectsFtsTable($db);
    } elseif ($indexName === 'fieldnotes') {
        ensureFieldnotesFtsTable($db);
    } else {
        throw new Exception("Invalid FTS index requested: $indexName");
    }

    $stmt = $db->prepare("SELECT IsDirty FROM search_index_meta WHERE IndexName = :indexName");
    $stmt->execute([':indexName' => $indexName]);
    $isDirty = (int)$stmt->fetchColumn();

    if ($indexName === 'projects') {
        $sourceCount = (int)$db->query("SELECT COUNT(*) FROM projects")->fetchColumn();
        $indexCount = (int)$db->query("SELECT COUNT(*) FROM projects_fts")->fetchColumn();
        if ($isDirty === 1 || $sourceCount !== $indexCount) {
            rebuildProjectsFtsIndex($db);
        }
    } else {
        $sourceCount = (int)$db->query("SELECT COUNT(*) FROM fieldnotes")->fetchColumn();
        $indexCount = (int)$db->query("SELECT COUNT(*) FROM fieldnotes_fts")->fetchColumn();
        if ($isDirty === 1 || $sourceCount !== $indexCount) {
            rebuildFieldnotesFtsIndex($db);
        }
    }

    return true;
}

function getProjectsBySearchLike($db, $rawTerm) {
    $term = '%' . $rawTerm . '%';
    $query = getProjectsBaseQuery() . "
        WHERE p.UUID LIKE :term
           OR p.Title LIKE :term
           OR p.ShortDescription LIKE :term
           OR p.Year LIKE :term
           OR m.Modality LIKE :term
           OR md.Medium LIKE :term
           OR t.Tool LIKE :term
           OR o.Object LIKE :term
           OR c.Collaborator LIKE :term
           OR k.Keyword LIKE :term
        GROUP BY p.UUID
    ";
    $stmt = $db->prepare($query);
    $stmt->execute([':term' => $term]);
    return $stmt->fetchAll();
}

function getFieldnotesBySearchLike($db, $rawTerm) {
    $term = '%' . $rawTerm . '%';
    $query = getFieldnotesBaseQuery() . "
        WHERE fn.UUID LIKE :term
           OR fn.Title LIKE :term
           OR fn.ShortDescription LIKE :term
           OR fn.PublishedDate LIKE :term
           OR fn.LastUpdated LIKE :term
    ";
    $stmt = $db->prepare($query);
    $stmt->execute([':term' => $term]);
    return $stmt->fetchAll();
}

// Main Action Switch
try {
    switch($action) {
        // Ontology (Projects) Actions
        case 'get_projects':
            $query = getProjectsBaseQuery() . " GROUP BY p.UUID";
            $stmt = $db->query($query);
            echo json_encode($stmt->fetchAll());
            break;

        case 'search_projects':
            $rawTerm = trim($_GET['term'] ?? '');

            if ($rawTerm === '') {
                $query = getProjectsBaseQuery() . " GROUP BY p.UUID";
                $stmt = $db->query($query);
                echo json_encode($stmt->fetchAll());
                break;
            }

            $useFts = ensureFtsSearchIndex($db, 'projects');
            $ftsMatchQuery = buildFtsMatchQuery($rawTerm);

            if ($useFts && $ftsMatchQuery !== '') {
                $query = getProjectsBaseQuery() . "
                    WHERE p.UUID IN (
                        SELECT UUID
                        FROM projects_fts
                        WHERE projects_fts MATCH :match
                    )
                    GROUP BY p.UUID
                ";
                $stmt = $db->prepare($query);
                $stmt->execute([':match' => $ftsMatchQuery]);
                echo json_encode($stmt->fetchAll());
            } else {
                echo json_encode(getProjectsBySearchLike($db, $rawTerm));
            }
            break;

        case 'get_distinct_projects':
            $field = $_GET['field'] ?? null;
            $tableMap = [
                'Modality' => ['table' => 'modalities', 'column' => 'Modality'],
                'Medium' => ['table' => 'mediums', 'column' => 'Medium'],
                'Tools' => ['table' => 'tools', 'column' => 'Tool'],
                'Object' => ['table' => 'objects', 'column' => 'Object'],
                'Collaborators' => ['table' => 'collaborators', 'column' => 'Collaborator'],
                'Keywords' => ['table' => 'keywords', 'column' => 'Keyword'],
                'Year' => ['table' => 'projects', 'column' => 'Year']
            ];

            if(isset($tableMap[$field])) {
                $table = $tableMap[$field]['table'];
                $column = $tableMap[$field]['column'];
                 if (!preg_match('/^[a-zA-Z0-9_]+$/', $column) || !preg_match('/^[a-zA-Z0-9_]+$/', $table)) {
                    throw new Exception("Invalid field or table name for distinct query.");
                }
                $stmt = $db->query("SELECT DISTINCT $column FROM $table WHERE $column IS NOT NULL AND $column != '' ORDER BY $column COLLATE NOCASE");
                echo json_encode($stmt->fetchAll(PDO::FETCH_COLUMN, 0));
            } elseif ($field === 'FeaturedWork') {
                echo json_encode(['TRUE', 'FALSE']);
            } else {
                 echo json_encode([]);
            }
            break;

        case 'query_projects':
            $conditions = $_GET['conditions'] ?? [];
            $whereResult = buildWhereClause($conditions, 'ontology');
            $query = getProjectsBaseQuery() . $whereResult['sql'] . " GROUP BY p.UUID";
            $stmt = $db->prepare($query);
            $stmt->execute($whereResult['params']);
            echo json_encode($stmt->fetchAll());
            break;

        case 'get_project_details':
            if (isset($_GET['url'])) {
                $url = $_GET['url'];
                $query = getProjectsBaseQuery() . " WHERE p.URL = :url GROUP BY p.UUID";
                $stmt = $db->prepare($query);
                $stmt->execute([':url' => $url]);
                $project = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($project) {
                    $arrayFields = ['Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords'];
                    foreach ($arrayFields as $field) {
                        if (isset($project[$field]) && is_string($project[$field])) {
                            $project[$field] = array_values(array_unique(explode(',', $project[$field])));
                        } else {
                            $project[$field] = [];
                        }
                    }
                    echo json_encode($project);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Project not found.']);
                }
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'Project URL not specified.']);
            }
            break;

        case 'get_fieldnote_details':
            if (isset($_GET['url'])) {
                $url = $_GET['url'];
                $query = "SELECT * FROM fieldnotes WHERE URL = :url";
                $stmt = $db->prepare($query);
                $stmt->execute([':url' => $url]);
                $fieldnote = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($fieldnote) {
                    echo json_encode($fieldnote);
                } else {
                    http_response_code(404);
                    echo json_encode(['error' => 'Fieldnote not found.']);
                }
            } else {
                http_response_code(400);
                echo json_encode(['error' => 'Fieldnote URL not specified.']);
            }
            break;

         // Fieldnotes Actions
        case 'get_fieldnotes':
             $query = getFieldnotesBaseQuery();
             $stmt = $db->query($query);
             echo json_encode($stmt->fetchAll());
            break;

        case 'search_fieldnotes':
             $rawTerm = trim($_GET['term'] ?? '');

             if ($rawTerm === '') {
                 $query = getFieldnotesBaseQuery();
                 $stmt = $db->query($query);
                 echo json_encode($stmt->fetchAll());
                 break;
             }

             $useFts = ensureFtsSearchIndex($db, 'fieldnotes');
             $ftsMatchQuery = buildFtsMatchQuery($rawTerm);

             if ($useFts && $ftsMatchQuery !== '') {
                 $query = getFieldnotesBaseQuery() . "
                           WHERE fn.UUID IN (
                               SELECT UUID
                               FROM fieldnotes_fts
                               WHERE fieldnotes_fts MATCH :match
                           )";
                 $stmt = $db->prepare($query);
                 $stmt->execute([':match' => $ftsMatchQuery]);
                 echo json_encode($stmt->fetchAll());
             } else {
                 echo json_encode(getFieldnotesBySearchLike($db, $rawTerm));
             }
            break;

        case 'get_distinct_fieldnotes':
             echo json_encode([]);
            break;

        case 'query_fieldnotes':
             $conditions = $_GET['conditions'] ?? [];
             $whereResult = buildWhereClause($conditions, 'fieldnotes');
             $query = getFieldnotesBaseQuery() . " " . $whereResult['sql'];
             $stmt = $db->prepare($query);
             $stmt->execute($whereResult['params']);
             echo json_encode($stmt->fetchAll());
            break;

         // Album Actions
        // case 'get_albums':
        //     $stmt = $db->query("SELECT * FROM albums");
        //     echo json_encode($stmt->fetchAll());
        //     break;

        // case 'search_albums':
        //      $term = '%' . ($_GET['term'] ?? '') . '%';
        //      $query = "SELECT * FROM albums a
        //                WHERE a.UUID LIKE :term
        //                OR a.FileName LIKE :term
        //                OR a.ShortDescription LIKE :term
        //                OR a.Camera LIKE :term
        //                OR a.Year LIKE :term";
        //      $stmt = $db->prepare($query);
        //      $stmt->execute([':term' => $term]);
        //      echo json_encode($stmt->fetchAll());
        //     break;

        // case 'get_distinct_albums':
        //      $field = $_GET['field'] ?? null;
        //      $allowedFields = ['Camera', 'Year'];
        //      if ($field && in_array($field, $allowedFields)) {
        //           if (!preg_match('/^[a-zA-Z0-9_]+$/', $field)) {
        //              throw new Exception("Invalid field name for distinct query.");
        //          }
        //          $stmt = $db->query("SELECT DISTINCT $field FROM albums WHERE $field IS NOT NULL AND $field != '' ORDER BY $field COLLATE NOCASE");
        //          echo json_encode($stmt->fetchAll(PDO::FETCH_COLUMN, 0));
        //      } else {
        //           echo json_encode([]);
        //      }
        //     break;

        // case 'query_albums':
        //     $conditions = $_GET['conditions'] ?? [];
        //     $whereResult = buildWhereClause($conditions, 'album');
        //     $query = "SELECT * FROM albums a " . $whereResult['sql']; 
        //     $stmt = $db->prepare($query);
        //     $stmt->execute($whereResult['params']);
        //     echo json_encode($stmt->fetchAll());
        //     break;

        default:
            echo json_encode(['error' => 'Invalid action specified.']);
    }
} catch(PDOException $e) {
    error_log("PDO Error in server.php: " . $e->getMessage());
    echo json_encode(['error' => 'Database query failed. Please check server logs.']);
} catch(Exception $e) {
     error_log("General Error in server.php: " . $e->getMessage());
    echo json_encode(['error' => 'An error occurred: ' . $e->getMessage()]);
}
?>
