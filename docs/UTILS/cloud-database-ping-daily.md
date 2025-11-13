# Cloud Database - Aiven Automation

This utility contains a simple, automated workflow to prevent a free-tier Aiven PostgreSQL database from being suspended due to inactivity.

## How It Works

It uses a single GitHub Actions workflow (.github/workflows/db-keep-alive.yml) that runs on a daily schedule (cron).

### The workflow:

- Spins up a lightweight Ubuntu runner.
- Installs the postgresql-client (which gives it the psql command).
- Connects to the Aiven database using credentials stored in GitHub Secrets.
- Runs a single, harmless query: SELECT now();.
- This single query is enough to register as "activity" and reset Aiven's inactivity timer.

## Setup

This workflow is designed to be "set it and forget it." To make it work in your own fork or repository, you only need to add your database credentials as GitHub Secrets.
1. Go to your repository's Settings > Secrets and variables > Actions.
2. Click New repository secret for each of the following:
     - `POSTGRES_HOST`: Your database host (e.g., your-project-pg-1234.aivencloud.com)
     - `POSTGRES_PORT`: The port number (e.g., 12345)
     - `POSTGRES_USER`: The username (usually avnadmin)
     - `POSTGRES_DB`: The database name (usually defaultdb)
     - `POSTGRES_PASSWORD`: The password for your avnadmin user.

Once these secrets are added, the workflow will automatically run on its defined schedule (default is 5:30 AM UTC daily) or whenever you trigger it manually from the "Actions" tab.