# --- BAT DAU NOI DUNG FILE shutdown-vps.ps1 (Version Co Lua Chon Nhom) ---

# Dinh nghia cac nhom VPS. Moi nhom la mot key trong hashtable.
# Gia tri cua moi key la mot mang (array) chua cac dia chi IP hoac ten may tinh.
# HAY THAY THE CAC DIA CHI IP/TEN MAY TINH TRONG CAC NHOM SAU DAY BANG CUA BAN
$vps_groups = @{
    "Nhom_Quan_Trong" = @(
        "103.253.21.231"
   
    );
    "Nhom_Phu_Tro" = @(
        "103.253.21.156"
   
    );
    "Tat_Ca_VPS" = @(
        "103.253.21.231",
        "103.253.21.156"
        # Dam bao tat ca cac IP/Hostname tu cac nhom khac duoc them vao day neu ban muon co lua chon tat ca
    );
    # Them cac nhom khac cua ban vao day theo cu phap "TenNhom" = @("IP1", "IP2", "Hostname3");
    # Vi du:
    # "Nhom_Dev" = @("Dev_VM_1", "Dev_VM_2");
}

# --- Lua chon nhom de tat ---
Write-Host "****************************************" -ForegroundColor Yellow
Write-Host "   Chon nhom VPS ban muon tat:   " -ForegroundColor Yellow
Write-Host "****************************************" -ForegroundColor Yellow

$groupNames = $vps_groups.Keys | Sort-Object # Sap xep ten nhom theo thu tu chu cai de de chon
for ($i = 0; $i -lt $groupNames.Count; $i++) {
    Write-Host "$($i + 1). $($groupNames[$i])"
}
Write-Host "0. Thoat"
Write-Host ""

$selectedGroupIndex = -1
while ($selectedGroupIndex -lt 0 -or $selectedGroupIndex -gt $groupNames.Count) {
    try {
        $input = Read-Host "Nhap so tuong ung voi nhom ban muon tat (0 de thoat)"
        $selectedGroupIndex = [int]$input
    }
    catch {
        Write-Host "Lua chon khong hop le. Vui long nhap mot so." -ForegroundColor Red
    }
}

if ($selectedGroupIndex -eq 0) {
    Write-Host "Da huy qua trinh. Thoat script." -ForegroundColor Yellow
    exit
}

$selectedGroupName = $groupNames[$selectedGroupIndex - 1]
$vps_targets = $vps_groups.$selectedGroupName

Write-Host ""
Write-Host "Ban da chon nhom: '$selectedGroupName'." -ForegroundColor Green
Write-Host "Danh sach cac VPS se bi tat:" -ForegroundColor Green
$vps_targets | ForEach-Object { Write-Host " - $_" -ForegroundColor Green }
Write-Host ""

# Kiem tra xem danh sach co trong khong sau khi lua chon
if ($vps_targets.Count -eq 0) {
    Write-Host "Canh bao: Nhom da chon khong co VPS nao. Khong co VPS nao de tat." -ForegroundColor Yellow
    exit
}

# Thong bao bat dau qua trinh
Write-Host "****************************************" -ForegroundColor Yellow
Write-Host "   Bat dau qua trinh tat cac VPS Windows trong nhom '$selectedGroupName'   " -ForegroundColor Yellow
Write-Host "****************************************" -ForegroundColor Yellow
Write-Host ""

# Lap qua tung IP/ten may tinh va gui lenh tat may
foreach ($target in $vps_targets) {
    # Loai bo khoang trang thua neu co
    $target = $target.Trim()

    # Bo qua cac dong trong
    if ([string]::IsNullOrWhiteSpace($target)) {
        continue
    }

    Write-Host "Dang co gang gui lenh tat may den: $($target)..." -ForegroundColor Cyan
    try {
        # Su dung lenh shutdown de tat may tu xa
        # /s : Tat may tinh
        # /f : Buoc dong cac ung dung dang chay ma khong canh bao
        # /m \\$target : Chi dinh may tinh tu xa
        # /t 0 : Dat thoi gian cho truoc khi tat la 0 giay (tat ngay lap tuc)
        # /c "..." : Them mot binh luan hien thi cho nguoi dung tren may dich
        # /d p:0:0 : Chi ro day la mot su kien tat may co ke hoach (tuy chon)

        Start-Process -FilePath "shutdown.exe" -ArgumentList "/s /f /m \\$target /t 0 /c `"Remote Shutdown by Admin`" /d p:0:0" -NoNewWindow -ErrorAction Stop

        Write-Host "   -> Lenh tat may da duoc gui thanh cong den $($target)." -ForegroundColor Green
    }
    catch {
        Write-Host "   -> Khong the gui lenh tat may den $($target). Loi: $($_.Exception.Message)" -ForegroundColor Red
        Write-Host "      Kiem tra: Ket noi mang, Firewall, Group Policy, va quyen Admin tren VM dich." -ForegroundColor Red
    }
    Write-Host "" # Them dong trong de de doc
}

Write-Host "****************************************" -ForegroundColor Yellow
Write-Host "   Qua trinh tat cac VPS da hoan tat.    " -ForegroundColor Yellow
Write-Host "****************************************" -ForegroundColor Yellow

# --- KET THUC NOI DUNG FILE shutdown-vps.ps1 (Version Co Lua Chon Nhom) ---
