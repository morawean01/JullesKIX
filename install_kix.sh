#!/bin/bash
# KIX Platform Installer

mkdir -p kix-frontend/public kix-iam kix-cortex/proto kix-south kix-street/config kix-harvester/config kix-sentinel

# --- Frontend ---
cat << 'EOF' > kix-frontend/public/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>KIX Dashboard 2026</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/gridstack.js/7.2.3/gridstack.min.css" />
    <script src="https://cdnjs.cloudflare.com/ajax/libs/gridstack.js/7.2.3/gridstack-all.js"></script>
    <link rel="stylesheet" href="styles.css">
    <script src="app.js" defer></script>
</head>
<body>
    <div id="login-overlay">
        <div class="login-box">
            <h2>KIX Login</h2>
            <input type="text" id="username" placeholder="Username" />
            <input type="password" id="password" placeholder="Password" />
            <button id="login-btn">ACCESS CORTEX</button>
        </div>
    </div>
    <div class="grid-stack"></div>
</body>
</html>
EOF

cat << 'EOF' > kix-frontend/public/styles.css
:root { --bg-color: #0d1117; --panel-bg: #161b22; --text-primary: #c9d1d9; --border-color: #30363d; --accent-cyan: #58a6ff; --accent-green: #238636; }
body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; background-color: var(--bg-color); color: var(--text-primary); margin: 0; padding: 0; height: 100vh; overflow: hidden; }
#login-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.85); display: flex; align-items: center; justify-content: center; z-index: 1000; }
.login-box { background: var(--panel-bg); padding: 40px; border-radius: 8px; border: 1px solid var(--border-color); width: 300px; text-align: center; }
.login-box input { width: 100%; padding: 10px; margin-bottom: 10px; background: #0d1117; border: 1px solid var(--border-color); color: white; border-radius: 4px; }
.login-box button { width: 100%; padding: 10px; background: var(--accent-green); color: white; border: none; border-radius: 4px; cursor: pointer; font-weight: bold; }
#dashboard { padding: 20px; height: 100%; }
.grid-stack-item-content { background-color: var(--panel-bg); border: 1px solid var(--border-color); border-radius: 6px; overflow: hidden; display: flex; flex-direction: column; }
.panel-header { padding: 10px; background: rgba(255,255,255,0.05); border-bottom: 1px solid var(--border-color); font-weight: 600; cursor: move; display: flex; justify-content: space-between; }
.panel-body { flex-grow: 1; padding: 10px; overflow-y: auto; }
::-webkit-scrollbar { width: 8px; }
::-webkit-scrollbar-track { background: var(--bg-color); }
::-webkit-scrollbar-thumb { background: var(--border-color); border-radius: 4px; }
EOF

cat << 'EOF' > kix-frontend/public/app.js
document.addEventListener('DOMContentLoaded', () => {
    const grid = GridStack.init({ column: 12, cellHeight: 80, margin: 5, dragOut: false, removable: true, handle: '.panel-header' });
    const defaultLayout = [
        { x: 0, y: 0, w: 8, h: 6, id: 'grid', content: '<div class="panel-header">Market Grid (Harvester Stream)</div><div class="panel-body" id="market-grid-body">Waiting for Harvester...</div>' },
        { x: 8, y: 0, w: 4, h: 4, id: 'control', content: '<div class="panel-header">Xetra Simulation Control</div><div class="panel-body" id="control-body">Loading Control Panel...</div>' },
        { x: 8, y: 4, w: 4, h: 2, id: 'status', content: '<div class="panel-header">Sentinel Status</div><div class="panel-body" id="status-body"><span style="color:#238636">● SENTINEL: ONLINE</span><br><span style="color:#d29922">● HARVESTER: CONNECTED</span><br><span style="color:#238636">● STREET: READY (FIX 4.4)</span></div>' },
        { x: 0, y: 6, w: 8, h: 3, id: 'orders', content: '<div class="panel-header">My Orders (Cortex)</div><div class="panel-body" id="my-orders-body">No Active Orders</div>' },
        { x: 8, y: 6, w: 4, h: 3, id: 'confirmations', content: '<div class="panel-header">Schlussnoten (Drop Copy)</div><div class="panel-body" id="confirmations-body">No Trades Yet</div>' }
    ];
    grid.load(defaultLayout);

    const loginOverlay = document.getElementById('login-overlay');
    const loginBtn = document.getElementById('login-btn');
    loginBtn.addEventListener('click', async () => {
        const user = document.getElementById('username').value;
        const pass = document.getElementById('password').value;
        try {
            if(user === 'demo') {
                loginOverlay.style.display = 'none';
                loadMarketData();
                renderControlPanel();
                renderConfirmations();
            } else {
                alert("Service Unavailable. Try 'demo' / 'demo'");
            }
        } catch (e) { console.error("Login Error:", e); }
    });

    function loadMarketData() {
        const body = document.getElementById('market-grid-body');
        body.innerHTML = `
            <table style="width:100%; border-collapse: collapse; color: #ccc;">
                <thead><tr style="border-bottom: 1px solid #333; text-align: left;"><th style="padding: 5px;">Symbol</th><th style="padding: 5px;">Bid</th><th style="padding: 5px;">Ask</th><th style="padding: 5px;">Vol</th></tr></thead>
                <tbody id="grid-rows"></tbody>
            </table>
        `;
        const symbols = ['AAPL', 'MSFT', 'GOOGL', 'AMZN', 'TSLA'];
        const rowsContainer = document.getElementById('grid-rows');
        symbols.forEach(sym => {
            const tr = document.createElement('tr');
            tr.innerHTML = `<td style="padding: 5px; color: #58a6ff;">${sym}</td><td style="padding: 5px;">${(Math.random() * 200 + 100).toFixed(2)}</td><td style="padding: 5px;">${(Math.random() * 200 + 100).toFixed(2)}</td><td style="padding: 5px;">${Math.floor(Math.random() * 10000)}</td>`;
            rowsContainer.appendChild(tr);
        });
    }

    function renderControlPanel() {
        const panel = document.getElementById('control-body');
        panel.innerHTML = `
            <div style="display: flex; flex-direction: column; gap: 10px;">
                <label style="display: flex; justify-content: space-between;"><span>Simulation Status:</span><span id="sim-status" style="color: #238636; font-weight: bold;">RUNNING</span></label>
                <button onclick="toggleSim()" style="background: #30363d; color: white; border: 1px solid #555; padding: 5px;">Start / Stop</button>
                <label>Fill Probability (0-100%):</label><input type="range" min="0" max="100" value="80" oninput="document.getElementById('fill-val').innerText = this.value + '%'"> <span id="fill-val" style="text-align: right;">80%</span>
                <label>Partial Fill Probability:</label><input type="range" min="0" max="100" value="20" oninput="document.getElementById('part-val').innerText = this.value + '%'"> <span id="part-val" style="text-align: right;">20%</span>
            </div>
        `;
    }

    function renderConfirmations() {
        const body = document.getElementById('confirmations-body');
        body.innerHTML = `
            <table style="width:100%; border-collapse: collapse; font-size: 12px; color: #ccc;">
                <thead><tr style="border-bottom: 1px solid #333; text-align: left;"><th style="padding: 5px;">Trade ID</th><th style="padding: 5px;">Sym</th><th style="padding: 5px;">Price</th><th style="padding: 5px;">Qty</th><th style="padding: 5px;">Counterparty</th></tr></thead>
                <tbody>
                    <tr><td style="padding: 5px;">XETR-9901</td><td style="padding: 5px; color: #d29922;">DAX</td><td style="padding: 5px;">15,430.50</td><td style="padding: 5px;">5</td><td style="padding: 5px;">XETR_CCP</td></tr>
                    <tr><td style="padding: 5px;">XETR-9902</td><td style="padding: 5px; color: #58a6ff;">SAP</td><td style="padding: 5px;">124.80</td><td style="padding: 5px;">200</td><td style="padding: 5px;">XETR_MM</td></tr>
                </tbody>
            </table>
        `;
    }

    window.toggleSim = function() {
        const status = document.getElementById('sim-status');
        if (status.innerText === 'RUNNING') { status.innerText = 'STOPPED'; status.style.color = '#da3633'; } else { status.innerText = 'RUNNING'; status.style.color = '#238636'; }
    };
});
EOF

cat << 'EOF' > kix-frontend/Dockerfile
FROM nginx:alpine
COPY public /usr/share/nginx/html
COPY nginx.conf /etc/nginx/nginx.conf
EXPOSE 80
EOF

cat << 'EOF' > kix-frontend/nginx.conf
worker_processes 1;
events { worker_connections 1024; }
http {
    include mime.types;
    default_type application/octet-stream;
    sendfile on;
    server {
        listen 80;
        root /usr/share/nginx/html;
        index index.html;
        location / { try_files $uri $uri/ /index.html; }
        location /api/auth/ { proxy_pass http://iam:8000/; }
    }
}
EOF

# --- IAM ---
cat << 'EOF' > kix-iam/requirements.txt
fastapi
uvicorn[standard]
sqlalchemy
psycopg2-binary
python-jose[cryptography]
passlib[bcrypt]
pydantic
EOF

cat << 'EOF' > kix-iam/Dockerfile
FROM python:3.10-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

cat << 'EOF' > kix-iam/main.py
from fastapi import FastAPI
app = FastAPI()
@app.get("/health")
def health(): return {"status": "ok"}
EOF

# --- Docker Compose ---
cat << 'EOF' > docker-compose.yml
version: '3.8'
services:
  cortex:
    build: ./kix-cortex
    ports: ["7071:7071"]
  south:
    image: postgres:15-alpine
    environment:
      POSTGRES_USER: kix
      POSTGRES_PASSWORD: kixpass
      POSTGRES_DB: kix_platform
  iam:
    build: ./kix-iam
    environment:
      DATABASE_URL: postgresql://kix:kixpass@south:5432/kix_platform
    ports: ["8000:8000"]
  frontend:
    build: ./kix-frontend
    ports: ["3000:80"]
EOF
