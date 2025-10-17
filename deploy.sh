#!/bin/bash

# =============================
# Local CI/CD Deployment Script
# =============================

LOG_FILE="./deploy.log"

echo "🚀 Starting deployment process at $(date)" | tee -a $LOG_FILE

# -----------------------------
# Step 0: Check current branch
# -----------------------------
branch=$(git rev-parse --abbrev-ref HEAD)
if [ "$branch" != "main" ]; then
  echo "⚠️ Not on main branch ($branch). Skipping deployment." | tee -a $LOG_FILE
  exit 0
fi

# -----------------------------
# Step 1: Pull latest code safely
# -----------------------------
echo "📥 Pulling latest code from GitHub..." | tee -a $LOG_FILE
git fetch origin main >> $LOG_FILE 2>&1
git checkout main >> $LOG_FILE 2>&1
git pull origin main >> $LOG_FILE 2>&1

# -----------------------------
# Step 2: Install dependencies
# -----------------------------
echo "📦 Installing dependencies..." | tee -a $LOG_FILE
npm install >> $LOG_FILE 2>&1

# -----------------------------
# Step 3: Run tests
# -----------------------------
echo "🧪 Running tests..." | tee -a $LOG_FILE
npm test >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Tests failed! Deployment aborted." | tee -a $LOG_FILE
  exit 1
fi

# -----------------------------
# Step 4: Build project
# -----------------------------
echo "🏗️ Building project..." | tee -a $LOG_FILE
npm run build >> $LOG_FILE 2>&1
if [ $? -ne 0 ]; then
  echo "❌ Build failed! Deployment aborted." | tee -a $LOG_FILE
  exit 1
fi

# -----------------------------
# Step 5: Restart PM2 process
# -----------------------------
APP_NAME="my-node-api"
DIST_FILE="dist/main.js"

echo "🔄 Restarting PM2 process..." | tee -a $LOG_FILE

# Stop process if exists
if pm2 list | grep -q $APP_NAME; then
  echo "🛑 Stopping existing PM2 process..." | tee -a $LOG_FILE
  pm2 stop $APP_NAME >> $LOG_FILE 2>&1
  pm2 delete $APP_NAME >> $LOG_FILE 2>&1
fi

# Start process
pm2 start $DIST_FILE --name $APP_NAME >> $LOG_FILE 2>&1

# Save PM2 process list for auto startup
pm2 save >> $LOG_FILE 2>&1

echo "✅ Deployment completed at $(date)" | tee -a $LOG_FILE
echo "🔗 See full log: $LOG_FILE"
