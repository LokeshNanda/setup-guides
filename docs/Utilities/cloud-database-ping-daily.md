# Aiven DB Keep-Alive

This repository contains a simple, automated workflow to prevent free-tier Aiven PostgreSQL and MySQL databases from being suspended due to inactivity.

## How It Works

It uses a single GitHub Actions workflow (.github/workflows/db-keep-alive.yml) that runs on a daily schedule (cron).

The workflow runs two jobs in parallel:

1. **PostgreSQL Job**:
   - Spins up a lightweight Ubuntu runner.
   - Installs the postgresql-client (which gives it the psql command).
   - Connects to the Aiven PostgreSQL database using credentials stored in GitHub Secrets.
   - Runs a single, harmless query: SELECT now();.

2. MySQL Job:
   - Spins up a lightweight Ubuntu runner.
   - Installs the mysql-client.
   - Connects to the Aiven MySQL database using credentials stored in GitHub Secrets.
   - Runs a single, harmless query: SELECT now();.

This activity is enough to register as "activity" on both services and reset Aiven's inactivity timer.

## Setup

This workflow is designed to be "set it and forget it." To make it work in your own fork or repository, you only need to add your database credentials as GitHub Secrets.

1. Go to your repository's **Settings > Secrets and variables > Actions**.
2. Click **New repository secret** for each of the following:

## PostgreSQL Secrets

- `POSTGRES_HOST`: Your database host (e.g., your-project-pg-1234.aivencloud.com)
- `POSTGRES_PORT`: The port number (e.g., 12345)
- `POSTGRES_USER`: The username (usually avnadmin)
- `POSTGRES_DB`: The database name (usually defaultdb)
- `POSTGRES_PASSWORD`: The password for your avnadmin user.

## MySQL Secrets

- `MYSQL_HOST`: Your MySQL host (e.g., your-project-mysql-5678.aivencloud.com)
- `MYSQL_PORT`: The port number (e.g., 54321)
- `MYSQL_USER`: The username (usually avnadmin)
- `MYSQL_DB`: The database name (usually defaultdb)
- `MYSQL_PASSWORD`: The password for your avnadmin user.

Once these secrets are added, the workflow will automatically run on its defined schedule (default is 5:30 AM UTC daily) or whenever you trigger it manually from the "Actions" tab.