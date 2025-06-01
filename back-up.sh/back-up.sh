#!/bin/bash

# Config
DATA_DIR="/data/n8n"
BACKUP_DIR="/backups"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_FILE="$BACKUP_DIR/n8n_backup_$TIMESTAMP.tar.gz"
RETENTION_DAYS=7

# Create backup directory if not exists
mkdir -p "$BACKUP_DIR"

# Archive the data directory
tar -czf "$BACKUP_FILE" -C "$DATA_DIR" .

# Check if backup was successful
if [ $? -eq 0 ]; then
  echo "✅ Backup saved to $BACKUP_FILE"
else
  echo "❌ Backup failed"
  exit 1
fi

# Cleanup old backups
find "$BACKUP_DIR" -type f -name "n8n_backup_*.tar.gz" -mtime +$RETENTION_DAYS -exec rm {} \;

echo "🧹 Old backups older than $RETENTION_DAYS days deleted."
