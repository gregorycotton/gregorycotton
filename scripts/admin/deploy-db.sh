#!/bin/bash

set -e

SERVER_USER="greg"
SERVER_IP="65.108.243.52"

LOCAL_DB_PATH="./database/projects.db"
REMOTE_DB_PATH="/var/www/gregorycotton.ca/database/projects.db"

echo "Deploying database update for gregorycotton.ca..."

if [ ! -f "$LOCAL_DB_PATH" ]; then
    echo "Error: Local database file not found at '$LOCAL_DB_PATH'"
    exit 1
fi

echo "⬆️  Uploading $LOCAL_DB_PATH to server..."
scp "$LOCAL_DB_PATH" ${SERVER_USER}@${SERVER_IP}:${REMOTE_DB_PATH}

echo "Setting permissions on the remote database file..."
ssh ${SERVER_USER}@${SERVER_IP} "
    sudo chown www-data:www-data $REMOTE_DB_PATH && \
    sudo chmod 664 $REMOTE_DB_PATH && \
    echo 'Remote permissions set successfully.'
"

echo "Database deployment complete."