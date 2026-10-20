#!/bin/sh
set -eu
umask 077
stamp=$(date -u +%Y%m%dT%H%M%SZ)
temporary="/backups/fitness-${stamp}.tmp"
target="/backups/fitness-${stamp}.dump"
trap 'rm -f "$temporary"' EXIT HUP INT TERM
pg_dump --format=custom --no-owner --no-acl --file="$temporary"
# Verify archive structure before publishing it or pruning earlier backups.
pg_restore --list "$temporary" >/dev/null
mv "$temporary" "$target"
find /backups -maxdepth 1 -type f -name 'fitness-*.dump' -mtime +14 -delete
echo "Database backup completed"
