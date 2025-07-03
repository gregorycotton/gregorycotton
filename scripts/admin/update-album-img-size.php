<?php

echo "Starting file size update process for the 'albums' table...\n";

$databaseFile = 'projects.db';

// Will need updating
$albumDirectoryPath = 'album/';

try {
    // Connect to DB
    $db = new PDO('sqlite:' . $databaseFile);
    $db->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "Successfully connected to the database.\n";

    // Fetch albums table records
    $stmt = $db->query("SELECT UUID, FileName FROM albums");
    $albums = $stmt->fetchAll(PDO::FETCH_ASSOC);

    if (empty($albums)) {
        echo "No albums found to update. Exiting.\n";
        exit;
    }

    echo "Found " . count($albums) . " album records to process.\n\n";

    // Prepare UPDATE statement
    $updateStmt = $db->prepare(
        "UPDATE albums SET SizeBytes = ? WHERE UUID = ?"
    );

    // Loop through records
    $successCount = 0;
    $errorCount = 0;

    foreach ($albums as $album) {
        $uuid = $album['UUID'];
        $fileName = $album['FileName'];
        
        // Construct file path
        $fullFilePath = rtrim($albumDirectoryPath, '/') . '/' . $fileName . '.jpg';

        if (file_exists($fullFilePath)) {
            // Fetch file size and update
            $fileSize = filesize($fullFilePath);
            
            $updateStmt->execute([$fileSize, $uuid]);
            
            echo "SUCCESS: Updated '{$fileName}' ({$uuid}) with size: " . number_format($fileSize) . " bytes.\n";
            $successCount++;
        } else {
            echo "ERROR: File not found for '{$fileName}' at path: {$fullFilePath}. Skipping.\n";
            $errorCount++;
        }
    }

    echo "\n----------------------------------------\n";
    echo "Process Complete.\n";
    echo "Successfully updated: {$successCount} records.\n";
    echo "Failed to find file for: {$errorCount} records.\n";

} catch (Exception $e) {
    echo "\nAN ERROR OCCURRED!\n";
    echo "Error message: " . $e->getMessage() . "\n";
    exit(1);
}

?>