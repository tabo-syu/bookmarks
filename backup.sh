#!/bin/bash

# バックアップファイル名に日付を追加
BACKUP_FILE="/backup/postgres-data_backup_$(date +%Y%m%d%H%M%S).tar"

# バックアップを作成
docker run --rm -v bookmarks-rails_postgres-data:/volume -v $(pwd)/backup:/backup busybox tar cvf $BACKUP_FILE /volume

# 古いバックアップファイルを削除（例：7日以上前のファイルを削除）
find $(pwd)/backup -type f -name "postgres-data_backup_*.tar" -mtime +7 -exec rm {} \;
