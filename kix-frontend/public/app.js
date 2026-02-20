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
