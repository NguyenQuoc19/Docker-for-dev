# MySQL Backup with phpMyAdmin

Docker Compose setup for MySQL + phpMyAdmin with auto backup, compression, and IP-restricted download.

## Project Structure

```
mysql-backup/
├── .env                    # Configuration file
├── .gitignore              # Git ignore
├── docker-compose.yml       # Docker compose config
├── Dockerfile.backup       # Backup container Dockerfile
├── README.md               # This file
├── backups/                # Backup files (auto-generated)
├── logs/                   # Log files
│   └── logrotate-mysql-backup
└── scripts/
    ├── .my.cnf             # MySQL credentials
    ├── backup/
    │   ├── backup.sh           # Backup all databases
    │   ├── backup-single.sh   # Backup single database
    │   ├── import.sh          # Import SQL file
    │   ├── list-backups.sh    # List backup files
    │   └── entrypoint.sh      # Container startup
    ├── cron/
    │   └── crontab           # Backup schedule
    └── nginx/
        └── nginx.conf        # Nginx config for downloads
```

## Services

| Container | Image | Description |
|-----------|-------|-------------|
| **db-mysql** | arm64v8/mysql:8.4 | MySQL database server |
| **db-phpmyadmin** | phpmyadmin:latest | Database management UI |
| **db-backup** | custom (debian) | Backup automation + Nginx proxy |

### Access URLs

| Service | URL | Credentials |
|---------|-----|-------------|
| phpMyAdmin | http://localhost:8334 | root / root@123 |
| Backup Download | http://localhost:8081 | IP-restricted |

### How It Works

- **db-backup** container runs both:
  - Nginx: serves backup files
  - Cron: auto backup (configurable in .env)
- **db-phpmyadmin** provides full-featured database management
- **db-mysql** provides the database

## Quick Start

```bash
docker compose up -d
```

## Configuration

Edit `.env` file:

```env
MYSQL_HOST=mysql
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=<your-password>

# Databases to backup (space separated)
MYSQL_DATABASES="test test1 test2"

BACKUP_DIR=/backups
RETENTION_DAYS=7

# Cron schedule (default: daily at 2 AM)
CRON_SCHEDULE=0 2 * * *

# Compression level (1-9): 1=fast, 9=smallest
COMPRESSION_LEVEL=6

# IP allowed to download backups (CIDR, single IP, or "all")
ALLOWED_IP=all
```

### Cron Schedule Examples

```env
# Every 5 minutes (to test)
CRON_SCHEDULE=*/5 * * * *

# Every hour
CRON_SCHEDULE=0 * * * *

# Every day at 2 AM (default)
CRON_SCHEDULE=0 2 * * *

# Every day at 2:30 AM
CRON_SCHEDULE=30 2 * * *

# Every Sunday at 3 AM
CRON_SCHEDULE=0 3 * * 0
```

### Compression Level

```env
# Level 1: Fastest (lower compression)
COMPRESSION_LEVEL=1

# Level 6: Balanced (default)
COMPRESSION_LEVEL=6

# Level 9: Smallest (slower)
COMPRESSION_LEVEL=9
```

> Uses pigz (parallel gzip) for multi-core compression - 4x faster than standard gzip!

### Configure Databases to Backup

```env
# Single database
MYSQL_DATABASES="test"

# Multiple databases (space separated)
MYSQL_DATABASES="test test1 test2 housai"

# All databases
# Note: Requires MySQL user with permission to read all databases
MYSQL_DATABASES="--all-databases"
```

> **Important:** After changing `.env`, restart the container:
> ```bash
> docker compose restart db-backup
> ```

### Enable/Disable Backup Download

```env
# Enable download on port 8081
BACKUP_PORT=8081

# Disable download (no external access)
BACKUP_PORT=
```

## Commands

### Start services
```bash
docker compose up -d
```

### Stop services
```bash
docker compose down
```

### View logs
```bash
docker logs db-backup
docker compose logs -f
```

### Manual backup
```bash
# Backup single database
docker exec db-backup /scripts/backup-single.sh <database_name>

# Example
docker exec db-backup /scripts/backup-single.sh test
```

### Backup all databases
```bash
docker exec db-backup /scripts/backup.sh
```

### List backups
```bash
docker exec db-backup ls -la /backups

# Or with download links
docker exec db-backup /scripts/list-backups.sh
```

## Import SQL File (Large File)

> **Note:** Import script automatically uses pigz (parallel gzip) for fast decompression!

### Method 1: Using import script (recommended)

```bash
# Copy SQL file to container
docker cp backup.sql db-backup:/backups/
# or for .gz file
docker cp backup.sql.gz db-backup:/backups/

# Import to database
docker exec db-backup /scripts/import.sh <database> /backups/backup.sql
docker exec db-backup /scripts/import.sh <database> /backups/backup.sql.gz
```

### Method 2: Direct import (requires password)

```bash
# Import SQL file
docker exec -i db-mysql mysql -uroot -p<password> <database> < backup.sql

# Import .gz file
gunzip < backup.sql.gz | docker exec -i db-mysql mysql -uroot -p<password> <database>
```

## Download Backup Files

### Get list of backup files
```bash
# From outside
curl -s http://<server-ip>:8081/
http://<server-ip>:8081/

# From inside container
docker exec db-backup /scripts/list-backups.sh
```

### Download specific file
```bash
curl -O http://<server-ip>:8081/<backup-file>
wget http://<server-ip>:8081/<backup-file>
```

### Download from inside container
```bash
docker cp db-backup:/backups/backup.sql.gz ./
```

## Restore Database

> **Note:** Use import script (recommended) - no password needed!

```bash
# Method 1: Using import script (recommended - no password needed)
docker cp backup.sql.gz db-backup:/backups/
docker exec db-backup /scripts/import.sh <database> /backups/backup.sql.gz

# Method 2: Direct restore (requires password)
docker exec -i db-mysql mysql -uroot -p<password> <database> < backup.sql

# Method 3: Using gunzip
gunzip < backup.sql.gz | docker exec -i db-mysql mysql -uroot -p<password> <database>
```

## Access

- **MySQL:** `localhost:3333`
- **phpMyAdmin:** `http://localhost:8334`
- **Backup Downloads:** `http://<server-ip>:8081`

## Benchmark (Performance Testing)

### Install sysbench (macOS)
```bash
brew install sysbench
```

### Run Benchmark

```bash
# Basic test with 50 threads, 60 seconds
MYSQL_PASSWORD=your_password ./benchmark.sh 50 60

# Custom threads and duration
MYSQL_PASSWORD=your_password ./benchmark.sh [threads] [duration]

# Examples:
MYSQL_PASSWORD=root@123 ./benchmark.sh 10 30   # 10 threads, 30s
MYSQL_PASSWORD=root@123 ./benchmark.sh 100 60 # 100 threads, 60s
```

### Benchmark Results (Current Config)

| Threads | QPS | P95 Latency | Suitable Users |
|---------|-----|-------------|----------------|
| 10 | 25,500 | <1ms | 250,000 |
| 50 | 32,768 | <1ms | 150,000 |
| 100 | 34,117 | <1ms | 100,000 |
| 200 | 30,117 | <1ms | 60,000 |
| 300 | 29,997 | <1ms | 50,000 |

> **Note:** Current config (1GB RAM, 400 max_connections) supports ~150,000 users with normal usage.

## Schedule

Auto backup schedule is configured in `.env` file via `CRON_SCHEDULE` variable.

```env
# Default: every 5 minutes
CRON_SCHEDULE=*/5 * * * *
```

After changing, restart container:
```bash
docker compose restart db-backup
```

## Security Recommendations

### For Production

1. **Change default password:**
```env
MYSQL_PASSWORD=your-strong-password-here
```

2. **Restrict IP access:**
```env
# Only allow specific IP
ALLOWED_IP=192.168.1.100

# Or IP range
ALLOWED_IP=192.168.1.0/24
```

3. **Remove MySQL port exposure** (if not needed):
```yaml
# Remove this line in docker-compose.yml for db-mysql
ports:
  - "3333:3306"
```

4. **Use SSL/TLS** for MySQL connections (requires additional configuration)

### File Permissions

```bash
# Secure .env file
chmod 600 .env

# Secure .my.cnf
chmod 600 scripts/.my.cnf
```
