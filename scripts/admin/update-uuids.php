<?php

echo "Starting UUID update process...\n";

$databaseFile = 'projects.db';

$tablesToUpdate = [
    'projects',
    'modalities',
    'mediums',
    'tools',
    'objects',
    'collaborators',
    'keywords',
];

// UUIDv4 gen
function generate_uuid_v4() {
    $data = random_bytes(16);

    $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
    $data[8] = chr(ord($data[8]) & 0x3f | 0x80);

    return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
}

try {
    // Connect to DB
    $db = new PDO('sqlite:' . $databaseFile);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);

    echo "Successfully connected to the database.\n";

    // Fetch existing UUIDs
    $stmt = $db->query("SELECT DISTINCT UUID FROM projects");
    $oldUuids = $stmt->fetchAll(PDO::FETCH_COLUMN, 0);

    if (empty($oldUuids)) {
        echo "No projects found to update. Exiting.\n";
        exit;
    }

    echo "Found " . count($oldUuids) . " unique projects to update.\n";

    // Map old:new UUID
    $uuidMap = [];
    foreach ($oldUuids as $oldUuid) {
        $uuidMap[$oldUuid] = generate_uuid_v4();
    }

    echo "Generated new UUIDv4s for all projects.\n";


    // Transaction
    $db->beginTransaction();
    echo "Transaction started. Beginning update process...\n";

    // Temp mapping table
    $db->exec("CREATE TEMP TABLE uuid_map (old_uuid TEXT PRIMARY KEY, new_uuid TEXT NOT NULL)");

    // Insert map into temp table
    $insertStmt = $db->prepare("INSERT INTO uuid_map (old_uuid, new_uuid) VALUES (?, ?)");
    foreach ($uuidMap as $old => $new) {
        $insertStmt->execute([$old, $new]);
    }
    echo "Temporary UUID map created and populated.\n";

    // Update table with map table
    foreach ($tablesToUpdate as $table) {
        echo "Updating table: $table ... ";
        $updateSql = "
            UPDATE {$table}
            SET UUID = (
                SELECT new_uuid
                FROM uuid_map
                WHERE uuid_map.old_uuid = {$table}.UUID
            )
            WHERE UUID IN (SELECT old_uuid FROM uuid_map)
        ";
        
        $affectedRows = $db->exec($updateSql);
        echo "Done. ($affectedRows rows affected).\n";
    }

    // Commit
    $db->commit();
    echo "\nTransaction committed successfully!\n";
    echo "All UUIDs have been updated to v4 format.\n";

} catch (Exception $e) {
    // Rollback as needed
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    echo "\nAN ERROR OCCURRED! All changes have been rolled back.\n";
    echo "Error message: " . $e->getMessage() . "\n";
    exit(1);
}

?>