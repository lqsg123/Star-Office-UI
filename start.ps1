$ErrorActionPreference = 'Stop'
$BASE = 'C:\Users\admin\.openclaw\workspace\Star-Office-UI'
$BACKEND = "$BASE\backend"
$STATE_FILE = "$BASE\state.json"
$LOG = "$env:TEMP\star_office_startup.log"

function Write-Log($msg) {
    $ts = Get-Date -Format 'HH:mm:ss'
    "[$ts] $msg" | Out-File -FilePath $LOG -Append -Encoding UTF8
    Write-Host "[$ts] $msg"
}

Write-Log "===== 启动开始 ====="

Write-Log "清理旧进程..."
Get-Process msedge,python -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep 2

Write-Log "启动 Flask 后端..."
$env:FLASK_APP = "app.py"
$env:STAR_OFFICE_STATE_FILE = $STATE_FILE
$env:PYTHONIOENCODING = "utf-8"

Start-Process python -ArgumentList "-m","flask","run","--host","127.0.0.1","--port","5000" -WorkingDirectory $BACKEND -WindowStyle Hidden -PassThru

for ($i = 0; $i -lt 30; $i++) {
    Start-Sleep 1
    try {
        Invoke-WebRequest -Uri "http://127.0.0.1:5000/status" -UseBasicParsing -TimeoutSec 2 | Out-Null
        Write-Log "Flask 后端就绪"
        break
    } catch {
        Write-Log "等待 Flask 启动... ($i/30)"
    }
}

Write-Log "打开 Edge 状态页..."
Start-Process msedge -ArgumentList "http://127.0.0.1:5000/mini","--window-title=dalxl" -PassThru | Out-Null
Start-Sleep 3

Write-Log "===== 启动完成 ====="
