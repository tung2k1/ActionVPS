# Cấu hình Proxmox API
# ĐẢM BẢO THAY THẾ CÁC GIÁ TRỊ SAU BẰNG THÔNG TIN CỦA BẠN
# Tạo một HashTable để ánh xạ IP của VPS với cấu hình Proxmox tương ứng
$ProxmoxConfig = @{
    "103.253.21.231" = @{VmId = 224; Node = "pve02"; Host = "103.214.9.48"} # THAY THẾ: VmId, Node, Host (IP Proxmox của bạn)
    
    # Nếu bạn có nhiều VPS, hãy thêm chúng vào đây theo định dạng tương tự:
    # "IP_CỦA_VPS_CỦA_BẠN" = @{VmId = ID_VM_TRÊN_PROXMOX; Node = "TÊN_NODE_PROXMOX"; Host = "IP_HOẶC_TEN_MIEN_PROXMOX_CỦA_BẠN"}
}

# Điền thông tin API Token bạn đã tạo trên Proxmox VE
# API Token ID sẽ có dạng: tên_người_dùng_API@realm!token_id (ví dụ: api_user_vps_control@pam!vps_control_token)
$ApiTokenId = "Tung-cloud@pve!vps_control_token" # <-- THAY THẾ BẰNG TOKEN ID ĐẦY ĐỦ CỦA BẠN TỪ BƯỚC TRƯỚC

# CẢNH BÁO AN TOÀN: LƯU TRỮ API TOKEN SECRET
# TUYỆT ĐỐI KHÔNG ĐỂ SECRET TRỰC TIẾP TRONG MỘT KHO LƯU TRỮ CÔNG KHAI!
# Nếu kho lưu trữ GitHub của bạn là PRIVATE, việc để Secret ở đây có rủi ro thấp hơn nhưng vẫn không phải là tốt nhất.
# Nếu bạn lo lắng về bảo mật, hãy cân nhắc các phương pháp khác như:
# 1. Yêu cầu nhập khi chạy script:
# $ApiTokenSecret = Read-Host -Prompt "Nhập Proxmox API Token Secret của bạn" -AsSecureString | ConvertFrom-SecureString
# 2. Đọc từ file cục bộ được bảo vệ (và thêm file đó vào .gitignore để không đẩy lên GitHub):
# $ApiTokenSecret = Get-Content -Path "C:\path\to\your\proxmox_api_secret.txt" -AsSecureString | ConvertFrom-SecureString
# 3. Sử dụng biến môi trường (Windows):
# $ApiTokenSecret = $env:PROXMOX_API_SECRET # Cần set biến này trước khi chạy script
#
# Hiện tại, bạn có thể dán Secret trực tiếp vào đây nếu repo của bạn là PRIVATE và bạn chấp nhận rủi ro:
$ApiTokenSecret = "b689808c-6e25-4f23-8851-7522a6fe7c9b"    # <-- THAY THẾ BẰNG CHUỖI SECRET DÀI MÀ BẠN ĐÃ SAO CHÉP

# Danh sách các địa chỉ IP hoặc tên máy tính của các VPS bạn muốn quản lý
# Đảm bảo các IP ở đây khớp với các "key" trong $ProxmoxConfig
$vpsList = @(
    "103.253.21.231"
    # Thêm các IP VPS khác của bạn vào đây
)

# Hỏi người dùng muốn thực hiện hành động gì
Write-Host "----------------------------------------------------"
Write-Host "  SCRIPT QUẢN LÝ VPS WINDOWS (Tích hợp Proxmox)"
Write-Host "----------------------------------------------------"
Write-Host "Nhập 'stop' để DỪNG NGUỒN các VPS qua Proxmox (cắt điện)."
Write-Host "Nhập 'start' để BẬT NGUỒN các VPS qua Proxmox."
Write-Host "Nhập 'reboot' để KHỞI ĐỘNG LẠI các VPS qua Proxmox."
Write-Host "Nhập 'exit' để thoát khỏi script."
Write-Host "----------------------------------------------------"

$action = Read-Host -Prompt "Lựa chọn của bạn"

switch ($action.ToLower()) {
    "stop" {
        Write-Host "Bạn đã chọn DỪNG NGUỒN các VPS qua Proxmox." -ForegroundColor Yellow
        foreach ($vps in $vpsList) {
            $config = $ProxmoxConfig[$vps]
            if ($config) {
                Write-Host "Đang gửi lệnh TẮT NGUỒN cho VPS '$vps' (Proxmox ID: $($config.VmId)) trên Proxmox node '$($config.Node)'..." -ForegroundColor Yellow
                try {
                    Invoke-PveVmStop -Node $($config.Node) -VmId $($config.VmId) -PVEHost $($config.Host) -ApiTokenId ${ApiTokenId} -ApiTokenSecret ${ApiTokenSecret} -Confirm:$false -ErrorAction Stop
                    Write-Host "Đã gửi lệnh TẮT NGUỒN thành công cho VPS '$vps' (Proxmox ID: $($config.VmId))." -ForegroundColor Green
                } catch {
                    Write-Host "Lỗi khi TẮT NGUỒN VPS '$vps' (Proxmox ID: $($config.VmId)): $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "Cấu hình Proxmox không tìm thấy cho VPS: ${vps}. Vui lòng kiểm tra \$ProxmoxConfig." -ForegroundColor Red
            }
        }
    }
    "start" {
        Write-Host "Bạn đã chọn BẬT NGUỒN các VPS qua Proxmox." -ForegroundColor Yellow
        foreach ($vps in $vpsList) {
            $config = $ProxmoxConfig[$vps]
            if ($config) {
                Write-Host "Đang gửi lệnh BẬT NGUỒN cho VPS '$vps' (Proxmox ID: $($config.VmId)) trên Proxmox node '$($config.Node)'..." -ForegroundColor Yellow
                try {
                    Invoke-PveVmStart -Node $($config.Node) -VmId $($config.VmId) -PVEHost $($config.Host) -ApiTokenId ${ApiTokenId} -ApiTokenSecret ${ApiTokenSecret} -Confirm:$false -ErrorAction Stop
                    Write-Host "Đã gửi lệnh BẬT NGUỒN thành công cho VPS '$vps' (Proxmox ID: $($config.VmId))." -ForegroundColor Green
                } catch {
                    Write-Host "Lỗi khi BẬT NGUỒN VPS '$vps' (Proxmox ID: $($config.VmId)): $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "Cấu hình Proxmox không tìm thấy cho VPS: ${vps}. Vui lòng kiểm tra \$ProxmoxConfig." -ForegroundColor Red
            }
        }
    }
    "reboot" {
        Write-Host "Bạn đã chọn KHỞI ĐỘNG LẠI các VPS qua Proxmox." -ForegroundColor Yellow
        foreach ($vps in $vpsList) {
            $config = $ProxmoxConfig[$vps]
            if ($config) {
                Write-Host "Đang gửi lệnh KHỞI ĐỘNG LẠI cho VPS '$vps' (Proxmox ID: $($config.VmId)) trên Proxmox node '$($config.Node)'..." -ForegroundColor Yellow
                try {
                    # Invoke-PveVmReset thực hiện "hard reset" (nhấn nút reset)
                    # Invoke-PveVmShutdown thực hiện shutdown mềm (như tắt máy từ HĐH) - cần Qemu Guest Agent trên VM
                    Invoke-PveVmReset -Node $($config.Node) -VmId $($config.VmId) -PVEHost $($config.Host) -ApiTokenId ${ApiTokenId} -ApiTokenSecret ${ApiTokenSecret} -Confirm:$false -ErrorAction Stop
                    Write-Host "Đã gửi lệnh KHỞI ĐỘNG LẠI thành công cho VPS '$vps' (Proxmox ID: $($config.VmId))." -ForegroundColor Green
                } catch {
                    Write-Host "Lỗi khi KHỞI ĐỘNG LẠI VPS '$vps' (Proxmox ID: $($config.VmId)): $($_.Exception.Message)" -ForegroundColor Red
                }
            } else {
                Write-Host "Cấu hình Proxmox không tìm thấy cho VPS: ${vps}. Vui lòng kiểm tra \$ProxmoxConfig." -ForegroundColor Red
            }
        }
    }
    "exit" {
        Write-Host "Thoát khỏi script. Tạm biệt!" -ForegroundColor Yellow
    }
    default {
        Write-Host "Lựa chọn không hợp lệ. Vui lòng nhập 'stop', 'start', 'reboot' hoặc 'exit'." -ForegroundColor Red
    }
}

Write-Host "----------------------------------------------------"
