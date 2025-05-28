# --- BẮT ĐẦU ĐOẠN MA POWERHSHELL TONG HOP ---

# 1. KHAI BAO CAC THONG TIN CAN THIET

# ######################################################################
# ########### THAY THE CAC URL DUOI DAY BANG URL RAW THUC TE CUA BAN ##########
# ######################################################################

# URL Raw cua file vps_list.txt tren GitHub repository cua ban
# Vi du: https://raw.githubusercontent.com/tung2k1/ActionVPS/main/vps_list.txt
$vpsListUrl = "https://raw.githubusercontent.com/tung2k1/ActionVPS/refs/heads/main/vps_list.txt";

# URL Raw cua file shutdown-vps.ps1 tren GitHub repository cua ban
# Vi du: https://raw.githubusercontent.com/tung2k1/ActionVPS/main/shutdown-vps.ps1
$scriptUrl = "https://raw.githubusercontent.com/tung2k1/ActionVPS/refs/heads/main/shutdown-vps.ps1";

# ######################################################################
# ######################################################################
# ######################################################################

# Duong dan thu muc tam thoi de luu cac file tai xuong
$downloadPath = "$env:TEMP\ShutdownVPS_TempFiles";

# Ten file script va danh sach sau khi tai ve
$vpsListName = "vps_list.txt";
$scriptName = "shutdown-vps.ps1";

# 2. CAU HINH EXECUTION POLICY (Chi can chay 1 lan duy nhat tren VM Nguon)
# Neu ban chua bao gio chay script PowerShell tu Internet, ban can thay doi Execution Policy.
# Luu y: 'RemoteSigned' an toan hon 'Bypass'.
Write-Host "Kiem tra va thiet lap Execution Policy..." -ForegroundColor Yellow
try {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    Write-Host "Execution Policy da duoc thiet lap thanh 'RemoteSigned'." -ForegroundColor Green
}
catch {
    Write-Host "Loi khi thiet lap Execution Policy: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Script co the khong chay duoc neu policy qua han che." -ForegroundColor Red
    Pause
    exit
}

# 3. TAO THU MUC TAM THOI
Write-Host "Tao thu muc tam thoi: $downloadPath..." -ForegroundColor Cyan
try {
    # Su dung -ErrorAction SilentlyContinue de tranh bao loi neu thu muc da ton tai
    New-Item -ItemType Directory -Path $downloadPath -ErrorAction SilentlyContinue | Out-Null
    Write-Host "Thu muc tam thoi da san sang." -ForegroundColor Green
}
catch {
    Write-Host "Loi khi tao thu muc tam thoi: $($_.Exception.Message)" -ForegroundColor Red
    Pause
    exit
}

# 4. TAI XUONG CAC FILE TU GITHUB
Write-Host "Dang tai danh sach VPS ($vpsListName) tu: $vpsListUrl" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $vpsListUrl -OutFile "$downloadPath\$vpsListName" -ErrorAction Stop
    Write-Host "Tai danh sach VPS thanh cong." -ForegroundColor Green
}
catch {
    Write-Host "Loi khi tai danh sach VPS: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vui long kiem tra URL hoac ket noi Internet." -ForegroundColor Red
    Pause
    exit
}

Write-Host "Dang tai script Shutdown VPS ($scriptName) tu: $scriptUrl" -ForegroundColor Cyan
try {
    Invoke-WebRequest -Uri $scriptUrl -OutFile "$downloadPath\$scriptName" -ErrorAction Stop
    Write-Host "Tai script Shutdown VPS thanh cong." -ForegroundColor Green
}
catch {
    Write-Host "Loi khi tai script Shutdown VPS: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vui long kiem tra URL hoac ket noi Internet." -ForegroundColor Red
    Pause
    exit
}

# 5. BO CHAN (UNBLOCK) FILE SCRIPT DA TAI XUONG
# Quan trong de script co the chay duoc neu Execution Policy la RemoteSigned
Write-Host "Dang bo chan file script: $scriptName..." -ForegroundColor Cyan
try {
    Unblock-File -Path "$downloadPath\$scriptName" -ErrorAction Stop
    Write-Host "File script da duoc bo chan." -ForegroundColor Green
}
catch {
    Write-Host "Loi khi bo chan file script: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Script co the khong chay duoc do bi chan boi he thong." -ForegroundColor Red
    Pause
    exit
}

# 6. CAP NHAT DUONG DAN vpsListFile TRONG SCRIPT DA TAI XUONG
# Dieu nay dam bao script se tim thay vps_list.txt trong thu muc tam thoi nay
Write-Host "Dang cap nhat duong dan vps_list.txt trong script..." -ForegroundColor Cyan
try {
    $scriptContent = Get-Content -Path "$downloadPath\$scriptName" -Encoding UTF8 # Doc voi encoding UTF8
    # Regex de tim bat cu duong dan nao ket thuc bang vps_list.txt
    # va thay the bang duong dan moi trong thu muc tam thoi
    $scriptContent = $scriptContent -replace "`$vpsListFile = \`".*?$vpsListName\`"", "`$vpsListFile = \`"$downloadPath\\$vpsListName\`""
    $scriptContent | Set-Content -Path "$downloadPath\$scriptName" -Encoding UTF8 # Ghi lai voi encoding UTF8
    Write-Host "Duong dan vps_list.txt trong script da duoc cap nhat." -ForegroundColor Green
}
catch {
    Write-Host "Loi khi cap nhat duong dan trong script: $($_.Exception.Message)" -ForegroundColor Red
    Pause
    exit
}

# 7. CHAY SCRIPT
Write-Host "****************************************" -ForegroundColor Yellow
Write-Host "   BAT DAU QUA TRINH TAT VPS THUC TE   " -ForegroundColor Yellow
Write-Host "****************************************" -ForegroundColor Yellow
Write-Host ""
Write-Host "Dang dieu huong den thu muc: $downloadPath va chay script..." -ForegroundColor Cyan

try {
    # Thay doi thu muc lam viec de script co the chay nhu binh thuong
    Set-Location -Path $downloadPath -ErrorAction Stop
    # Chay script
    & ".\$scriptName"
}
catch {
    Write-Host "Loi khi chay script chinh: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Vui long kiem tra noi dung script hoac thiet lap he thong." -ForegroundColor Red
}

Write-Host "****************************************" -ForegroundColor Yellow
Write-Host "   QUA TRINH TONG HOP DA HOAN TAT.    " -ForegroundColor Yellow
Write-Host "****************************************" -ForegroundColor Yellow

# 8. (TUY CHON) DON DEP CAC FILE TAM THOI
# Neu ban muon tu dong xoa cac file sau khi chay, bo dau # o dong duoi
# Write-Host "Dang don dep cac file tam thoi..." -ForegroundColor Cyan
# Remove-Item -Path $downloadPath -Recurse -Force -ErrorAction SilentlyContinue
# Write-Host "Don dep da hoan tat." -ForegroundColor Green

# --- KET THUC DOAN MA POWERHSHELL TONG HOP ---
