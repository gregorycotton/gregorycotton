<?php

echo "Starting blank UUID update process...\n";

$databaseFile = 'projects.db';

$tablesToUpdate = [
    'projects',
    'modalities',
    'mediums',
    'tools',
    'objects',
    'collaborators',
    'keywords'
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

    // Check master table for blank UUID field
    $checkSql = "SELECT COUNT(*) FROM projects WHERE UUID IS NULL OR UUID = ''";
    $projectCount = $db->query($checkSql)->fetchColumn();

    if ($projectCount == 0) {
        echo "No projects found with a blank UUID. Nothing to do.\n";
        exit;
    }
    
    // Only one blank UUID at a time dummy
    echo "Found {$projectCount} project(s) with a blank UUID.\n";

    // UUIDv4 gen for blank record(s)
    $newUuid = generate_uuid_v4();
    echo "Assigning new shared UUID: {$newUuid}\n";

    // Transaction
    $db->beginTransaction();
    echo "Transaction started. Beginning update process...\n";

    // Update blank UUID field to generated UUID
    foreach ($tablesToUpdate as $table) {
        echo "Updating table: {$table} ... ";
        
        $updateStmt = $db->prepare(
            "UPDATE {$table} SET UUID = ? WHERE UUID IS NULL OR UUID = ''"
        );
        
        $updateStmt->execute([$newUuid]);
        $affectedRows = $updateStmt->rowCount();
        
        echo "Done. ({$affectedRows} rows affected).\n";
    }

    // Commit
    $db->commit();
    echo "\nTransaction committed successfully!\n";
    echo "All blank UUID records have been updated.\n";

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