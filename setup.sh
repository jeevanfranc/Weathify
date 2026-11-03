#!/bin/bash

# Weathify Setup Script
# This script sets up the database and creates an admin user

set -e
set -o pipefail

echo "Weathify Setup Script"
echo "======================="
echo ""

# Check if .env exists
if [ ! -f .env ]; then
    echo " Error: .env file not found"
    echo "Please copy .env.example to .env and configure it first"
    echo "Run: cp .env.example .env"
    exit 1
fi

# Load environment variables
source .env

# Require an admin password
if [ -z "${ADMIN_PASS}" ]; then
    echo " Error: ADMIN_PASS is not set in .env"
    echo "Set ADMIN_PASS before running setup.sh"
    exit 1
fi

# Check if PostgreSQL is installed
if ! command -v psql &> /dev/null; then
    echo " Error: PostgreSQL is not installed"
    echo "Please install PostgreSQL first"
    exit 1
fi

echo " PostgreSQL found"
echo ""

# Check if database exists
if psql -h localhost -U ${DB_USER} -lqt | cut -d \| -f 1 | grep -qw ${DB_NAME}; then
    echo "⚠️  Database '${DB_NAME}' already exists"
    read -p "Do you want to drop and recreate it? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Dropping database..."
        dropdb -h localhost -U ${DB_USER} ${DB_NAME} || true
    else
        echo "Keeping existing database"
    fi
fi

# Create database if it doesn't exist
if ! psql -h localhost -U ${DB_USER} -lqt | cut -d \| -f 1 | grep -qw ${DB_NAME}; then
    echo " Creating database '${DB_NAME}'..."
    createdb -h localhost -U ${DB_USER} ${DB_NAME}
    echo " Database created"
else
    echo " Using existing database"
fi

echo ""

# Run schema
echo " Running database schema..."
psql -h localhost -U ${DB_USER} -d ${DB_NAME} -f backend/database/schema.sql

echo ""
echo " Database setup complete!"
echo ""

# Prompt for admin password change
echo " Admin Account Setup"
echo "====================="
echo ""
echo "Setting admin password..."
export ADMIN_PASS
(cd backend && node database/seed_admin.js --reset) > /dev/null
echo " Admin password updated!"

echo ""
echo "🎉 Setup Complete!"
echo ""
echo "Next steps:"
echo "1. Configure your .env file with API credentials"
echo "2. Run 'npm install' to install dependencies"
echo "3. Run 'npm run dev' to start the development server"
echo "4. Visit http://localhost:3000"
echo ""