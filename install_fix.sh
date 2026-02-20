#!/bin/bash
# KIX Platform - Fix & Installer

echo "Creating all missing files..."

mkdir -p kix-cortex/proto

# 1. Create Cortex Dockerfile (This was missing!)
cat << 'EOF' > kix-cortex/Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["python", "-c", "import time; print('KIX Cortex Started'); time.sleep(3600)"]
EOF

cat << 'EOF' > kix-cortex/requirements.txt
grpcio
grpcio-tools
protobuf
psycopg2-binary
EOF

# 2. Create Git Setup Script (Use this to push!)
cat << 'EOF' > setup_git.sh
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
EOF

chmod +x setup_git.sh

echo "Finished! Now run: ./setup_git.sh"
