$ErrorActionPreference = 'Stop'
$BASE = 'C:\Users\admin\.openclaw\workspace\Star-Office-UI'
$ELECTRON_DIR = "$BASE\electron-shell"

Write-Output "Starting Star Office UI (Electron)..."

# Kill old processes
Get-Process electron -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process msedge -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2

# Start Flask backend
Write-Output "Starting Flask backend..."
$env:FLASK_APP = 'app.py'
$env:STAR_OFFICE_STATE_FILE = "$BASE\state.json"
$env:PYTHONIOENCODING = 'utf-8'
Start-Process python -ArgumentList '-m','flask','run','--host','127.0.0.1','--port','5000' -WorkingDirectory "$BASE\backend" -WindowStyle Hidden -PassThru

# Wait for Flask
for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep 1
    try {
        Invoke-WebRequest -Uri 'http://127.0.0.1:5000/status' -UseBasicParsing -TimeoutSec 2 | Out-Null
        Write-Output "Flask backend ready"
        break
    } catch {}
}

# Start Electron fullscreen window
Write-Output "Starting Electron window..."
$env:STAR_BACKEND_PORT = '5000'
$env:STAR_BACKEND_HOST = '127.0.0.1'
Start-Process "$ELECTRON_DIR\node_modules\.bin\electron.cmd" -ArgumentList '.' -WorkingDirectory $ELECTRON_DIR -PassThru

Write-Output "Star Office UI started"
