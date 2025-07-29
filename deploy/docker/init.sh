#!/bin/bash

# This script is the entrypoint for the Django application container.
# It handles database readiness, Django migrations, static file collection,
# and then starts the Gunicorn server.

echo "Starting QATrack+ initialization script..."

# --- Wait for PostgreSQL to be ready ---
# This loop waits until the PostgreSQL database is accepting connections.
# It's crucial to ensure the database is fully up before Django tries to connect.
echo "Waiting for PostgreSQL to be ready..."
# Corrected pg_isready syntax: ensure the username is properly quoted.
until pg_isready -h db -p 5432 -U "${POSTGRES_USER}"; do
  echo "PostgreSQL is unavailable - sleeping"
  sleep 1
done
echo "PostgreSQL is up and running!"

# --- Run Django database migrations ---
# This applies any pending database migrations to ensure the schema is up-to-date.
echo "Running Django migrations..."
python manage.py migrate --noinput

# --- Collect static files ---
# This gathers all static files from Django apps into a single directory
# so Nginx can serve them.
echo "Collecting static files..."
python manage.py collectstatic --noinput

# --- Create Django cache table ---
# This command sets up the database table required for Django's database cache backend.
echo "Creating Django cache table..."
python manage.py createcachetable

# --- Start Gunicorn (Django application server) ---
# Gunicorn will serve the Django application, listening on port 8000.
# Nginx will then proxy requests to this port.
echo "Starting Gunicorn..."
# The -b :8000 binds Gunicorn to all network interfaces on port 8000.
# The -w 2 sets the number of worker processes (adjust based on your server's CPU cores).
gunicorn qatrack.wsgi:application -w 2 -b :8000

# Note: If you need to create a superuser for the first time, you can do so
# by running 'docker compose exec app python manage.py createsuperuser'
# after the containers are up and running.
