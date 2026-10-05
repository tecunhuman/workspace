.DEFAULT_GOAL := backup

.PHONY: backup backup-check backup-delete

backup:
	./scripts/backup.sh

backup-check:
	./scripts/backup.sh --dry-run

backup-delete:
	./scripts/backup.sh --delete
