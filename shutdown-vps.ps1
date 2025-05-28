# --- BẮT ĐẦU ĐOẠN MA POWERHSHELL (Version Khong Dau) ---

# Duong dan den file chua danh sach cac VM Dich
# Dam bao duong dan nay khop voi vi tri ban da luu vps_list.txt
# Vi du: $vpsListFile = "C:\Users\cloudadmin\Documents\actionvps\vps_list.txt"
$vpsListFile = "C:\Users\cloudadmin\Documents\actionvps\vps_list.txt" # Thay the <username> bang ten nguoi dung cua ban

# Kiem tra xem file danh sach co ton tai khong
if (-not (Test-Path $vpsListFile)) {
    Write-Host "Loi: Khong tim thay file danh sach VPS tai '$vpsListFile'." -ForegroundColor Red
    Write-Host "Vui long kiem tra lai duong dan va ten file." -ForegroundColor Red
    exit
}

# Doc danh sach cac VM tu file
$vps_targets = Get-Content $vpsListFile

# Kiem tra xem danh sach co trong khong
if ($vps_targets.Count -eq 0) {
    Write-Host "Canh bao: File danh sach VPS '$vpsListFile' trong. Khong co VPS nao de tat." -ForegroundColor Yellow
    exit
}

# Thong bao bat dau qua trinh
Write-Host "****************************************" -ForegroundColor Yellow
Write-Host "   Bat dau qua trinh tat cac VPS Windows   " -ForegroundColor Yellow
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

# --- KET THUC DOAN MA POWERHSHELL ---
