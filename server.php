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
    // $db = new PDO('sqlite:/var/www/gregorycotton.ca/database/projects.db');
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
        case 'album': $mainTableAlias = 'a'; break;
        default: throw new Exception("Invalid view type specified: $viewType");
    }

    $validFields = [];
     switch($viewType) {
        case 'ontology': $validFields = ['UUID', 'Title', 'ShortDescription', 'Year', 'Modality', 'Medium', 'Tools', 'Object', 'Collaborators', 'Keywords', 'FeaturedWork']; break;
        case 'fieldnotes': $validFields = ['UUID', 'Title', 'ShortDescription', 'PublishedDate', 'LastUpdated']; break;
        case 'album': $validFields = ['UUID', 'FileName', 'ShortDescription', 'Camera', 'SizeBytes', 'Year']; break;
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
            $term = '%' . ($_GET['term'] ?? '') . '%';
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
            echo json_encode($stmt->fetchAll());
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
             $term = '%' . ($_GET['term'] ?? '') . '%';
             $query = getFieldnotesBaseQuery() . "
                       WHERE fn.UUID LIKE :term
                       OR fn.Title LIKE :term
                       OR fn.ShortDescription LIKE :term
                       OR fn.PublishedDate LIKE :term
                       OR fn.LastUpdated LIKE :term";
             $stmt = $db->prepare($query);
             $stmt->execute([':term' => $term]);
             echo json_encode($stmt->fetchAll());
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
        case 'get_albums':
            $stmt = $db->query("SELECT * FROM albums");
            echo json_encode($stmt->fetchAll());
            break;

        case 'search_albums':
             $term = '%' . ($_GET['term'] ?? '') . '%';
             $query = "SELECT * FROM albums a
                       WHERE a.UUID LIKE :term
                       OR a.FileName LIKE :term
                       OR a.ShortDescription LIKE :term
                       OR a.Camera LIKE :term
                       OR a.Year LIKE :term";
             $stmt = $db->prepare($query);
             $stmt->execute([':term' => $term]);
             echo json_encode($stmt->fetchAll());
            break;

        case 'get_distinct_albums':
             $field = $_GET['field'] ?? null;
             $allowedFields = ['Camera', 'Year'];
             if ($field && in_array($field, $allowedFields)) {
                  if (!preg_match('/^[a-zA-Z0-9_]+$/', $field)) {
                     throw new Exception("Invalid field name for distinct query.");
                 }
                 $stmt = $db->query("SELECT DISTINCT $field FROM albums WHERE $field IS NOT NULL AND $field != '' ORDER BY $field COLLATE NOCASE");
                 echo json_encode($stmt->fetchAll(PDO::FETCH_COLUMN, 0));
             } else {
                  echo json_encode([]);
             }
            break;

        case 'query_albums':
            $conditions = $_GET['conditions'] ?? [];
            $whereResult = buildWhereClause($conditions, 'album');
            $query = "SELECT * FROM albums a " . $whereResult['sql']; 
            $stmt = $db->prepare($query);
            $stmt->execute($whereResult['params']);
            echo json_encode($stmt->fetchAll());
            break;

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
