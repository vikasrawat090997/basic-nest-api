#!/bin/bash

echo "🚀 Starting deployment..."
echo "Pulling latest code from main branch"
git reset --hard
git pull origin main

echo "Installing dependencies"
npm install

echo "Building project"
npm run build

echo "Restarting server with PM2"
pm2 stop my-nest-api || true
pm2 start dist/main.js --name my-nest-api

echo "✅ Deployment finished"
