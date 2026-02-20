#!/bin/bash
# Pushes code to GitHub

# Set your repo URL here if different
REPO_URL="https://github.com/morawean01/JullesKIX.git"

echo "Initializing Git..."
git init
git add .
git commit -m "Fix: Add missing Cortex Dockerfile and complete architecture"
git branch -M main
git remote add origin "$REPO_URL" 2>/dev/null || git remote set-url origin "$REPO_URL"

echo "----------------------------------------------------------------"
echo "PUSHING TO GITHUB: $REPO_URL"
echo "You will be asked for your Username and Password."
echo "NOTE: For Password, use your GitHub Personal Access Token (PAT)!"
echo "----------------------------------------------------------------"

git push -u origin main
