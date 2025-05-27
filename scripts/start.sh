#!/bin/bash
set -e

# Wait for database to be ready
echo "Waiting for database to be ready..."
npx wait-on -t 60000 $DATABASE_URL

# Run database migrations
echo "Running database migrations..."
yarn db-deploy

# Seed the database if needed
echo "Seeding database..."
yarn --cwd packages/prisma seed-app-store

# Start the application
echo "Starting application..."
yarn start
